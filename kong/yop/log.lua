local ngx = ngx

local _M = {}

local COLON = ": "

function _M.notice_u(uuid, ...) ngx.log(ngx.NOTICE, uuid, COLON, ...) end

function _M.warn_u(uuid, ...) ngx.log(ngx.WARN, uuid, COLON, ...) end

function _M.notice(...) ngx.log(ngx.NOTICE, ngx.ctx.uuid, COLON, ...) end

function _M.warn(...) ngx.log(ngx.WARN, ngx.ctx.uuid, COLON, ...) end

function _M.error(...) ngx.log(ngx.ERR, ngx.ctx.uuid, COLON, ...) end

return _M