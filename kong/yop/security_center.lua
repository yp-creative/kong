--
-- Created by IntelliJ IDEA.
-- User: jrk
-- Date: 16/8/3
-- Time: 下午3:43
-- To change this template use File | Settings | File Templates.
--
local codec = require 'codec'
local mcrypt = require 'mcrypt'

local _M = {}

local SIGN_ALGS = {
  SHA1 = function(body) return codec.sha1_encode(body) end,
  SHA256 = function(body) return codec.sha256_encode(body) end,
  MD5 = function(body) return codec.md5_encode(body) end,
}

local DECRYPT_ALGS = {
  DB_BASED = function(body, secret) return codec.aes_decrypt(codec.base64_decode(body), codec.base64_decode(secret)) end,
  CUST_BASED = function(body, secret)
    secret = codec.md5_encode(secret)
    return mcrypt.bf_cfb_de(secret:sub(1, 16), secret:sub(1, 8), codec.base64_decode(body))
  end
}

local ENCRYPT_ALGS = {
  DB_BASED = function(body, secret)
    return codec.base64_encode(codec.aes_encrypt(body, codec.base64_decode(secret)))
  end,
  CUST_BASED = function(body, secret)
    secret = codec.md5_encode(secret)
    return codec.base64_encode(mcrypt.bf_cfb_en(secret:sub(1, 16), secret:sub(1, 8), body))
  end
}

--解密请求
function _M.decryptRequest(keyStoreType, body, secret)
  return DECRYPT_ALGS[keyStoreType](body, secret)
end

--加密响应
function _M.encryptResponse(keyStoreType, body, secret) return ENCRYPT_ALGS[keyStoreType](body, secret) end

function _M.sign(alg, body) return SIGN_ALGS[alg](body) end

return _M