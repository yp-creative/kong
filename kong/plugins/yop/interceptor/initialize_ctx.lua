--
-- 上下文初始化拦截器
-- -- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:18
-- To change this template use File | Settings | File Templates.
--
local readRequestBody = ngx.req.read_body
local getRequestBody = ngx.req.get_body_data
local ngxDecodeArgs = ngx.decode_args

local getRequestMethod = ngx.req.get_method

local cache = require 'kong.yop.cache'
local response, _ = require 'kong.yop.response'()
local singletons = require "kong.singletons"
local stringy = require "stringy"

local next = next
local ngx = ngx
local ngxVar = ngx.var
local decodeOnceToString = ngx.unescape_uri

local _M = {}

local PREFIX_LENGTH = 1 + #"/yop-center"
local YOP_CENTER_URL = singletons.configuration["yop_center_url"]
if stringy.endswith(YOP_CENTER_URL, "/") then YOP_CENTER_URL = YOP_CENTER_URL:sub(1, #YOP_CENTER_URL - 1) end

local function decodeOnceToTable(body) if body then return ngxDecodeArgs(body) end return {} end

local getOriginalParameters = {
  GET = function() return ngxVar.args end,
  POST = function() readRequestBody() return getRequestBody() end
}

_M.process = function(ctx)
  local apiUri = ngxVar.uri:sub(PREFIX_LENGTH)

  --  从缓存中获取api信息，如果不存在，就调用远程接口获取api信息并缓存
  local api = cache.cacheApi(apiUri)

  --  api校验
  if api == nil or next(api) == nil then response.apiNotExistException(apiUri) end
  if api.status ~= 'ACTIVE' then response.apiUnavailableException(apiUri) end

  --  如果是未迁移api，直接转发至yop-center
  if api.fork == "YOP_CENTER" then ctx.nginx, ngx.ctx.skipBodyFilter, ngx.ctx.upstream_url = false, true, YOP_CENTER_URL .. apiUri return end

  local method = getRequestMethod()

  --  parameters需要做2次urldecode
  local parameters = decodeOnceToTable(decodeOnceToString(getOriginalParameters[method]()))

  local appKey
  if parameters.appKey then
    appKey, ctx.keyStoreType = parameters.appKey, 'DB_BASED'
  else
    appKey, ctx.keyStoreType = parameters.customerNo, "CUST_BASED"
  end
  --  缺少appKey参数
  if appKey == nil then response.missParameterException("", "appKey") end

  local app = cache.cacheApp(appKey)
  --  app校验
  if app == nil or next(app) == nil or app.status ~= 'ACTIVE' then response.appUnavailableException(appKey) end

  --初始化ctx
  --apiUri,eg: /rest/v2.0/auth/enterprise
  --appKey,eg: yop-boss
  ctx.apiUri, ctx.appKey = apiUri, appKey
  --api,app
  ctx.api, ctx.app = api, app
  --http请求方法，GET/POST
  ctx.method = method
  --请求参数
  ctx.parameters = parameters
  --请求ip
  ctx.ip = ngxVar.remote_addr

  --参数转换
  ctx.transformer = cache.getTransformer(apiUri)
  --参数校验
  ctx.validator = cache.getValidator(apiUri)
  --  参数默认值
  ctx.defaultValues = cache.getDefaultValues(apiUri)
  --忽略签名字段
  ctx.ignoreSignFields = cache.getIgnoreSignFields(apiUri)

  --  ip白名单
  ctx.whitelist = cache.cacheIPWhitelist(apiUri)
  --  授权信息
  ctx.auth = cache.cacheAppAuth(appKey)

  --负载均衡信息
  ctx.upstreams = cache.cacheUpstream(api.backendApp)


  --保存于ngx上下文中的信息，用于对结果进行加密签名处理
  --ngx.ctx中的信息生命周期为单个request，但使用代价较高
  if parameters.encrypt then
    --    是否加密，以及加密算法的选择
    ngx.ctx.encrypt, ngx.ctx.keyStoreType = true, ctx.keyStoreType
  end
  ngx.ctx.signAlg = api.signAlg
  ngx.ctx.appSecret = app.appSecret -- 将 appSercet 作为全局变量放在ngx.ctx里面,供转发后返回加密和签名使用/
end

return _M

