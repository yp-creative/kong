--
-- Created by IntelliJ IDEA.
-- User: jrk
-- Date: 16/8/3
-- Time: 下午3:43
-- To change this template use File | Settings | File Templates.
--
local codec = require 'codec'
local mcrypt = require 'mcrypt'

local string, table = string, table

local _M = {}

function _M.blowfishDecrypt(body, secret)
  local pwd = codec.md5_encode(secret)
  local key = string.sub(pwd, 1, 16)
  local iv = string.sub(pwd, 1, 8)
  return mcrypt.bf_cfb_de(key, iv, codec.base64_decode(body))
end

function _M.aesDecryptWithKeyBase64(body, secret)
  return codec.aes_decrypt(codec.base64_decode(body), codec.base64_decode(secret));
end

local SIGN_ALGS = {
  SHA1 = function(body) return codec.sha1_encode(body) end,
  SHA256 = function(body) return codec.sha256_encode(body) end,
  MD5 = function(body) return codec.md5_encode(body) end,
}

local function blowfishEncrypt(body, secret)
  local pwd = codec.md5_encode(secret)
  local key = string.sub(pwd, 1, 16)
  local iv = string.sub(pwd, 1, 8)
  return mcrypt.bf_cfb_en(key, iv, body)
end

local function aesEncryptWithKeyBase64(body, secret)
  return codec.aes_encrypt(body, codec.base64_decode(secret));
end

function _M.signRawString(rawString, alg) return SIGN_ALGS[alg](rawString) end

function _M.signResponse(r, appSecret, alg)
  r.sign = _M.signRawString(table.concat({ appSecret, r.state, r.result, r.ts, appSecret }), alg)
end

function _M.encryptResponse(r, keyStoreType, appSecret)
  if (keyStoreType == "CUST_BASED") then
    r.result = codec.base64_encode(blowfishEncrypt(r.result, appSecret))
  else
    r.result = codec.base64_encode(aesEncryptWithKeyBase64(r.result, appSecret))
  end
end

return _M