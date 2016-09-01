lua-mcrypt工具包
=======================================================
基于mcrypt，实现Blowfish加解密，具体功能参见示例代码；


编译说明
-------------------------------------------------------
cd resources/mcrypt/
make
mv mcrypt.so $YOUR_LUA_PACKAGE_PATH（如：/usr/local/lib/lua/5.1）


Lua代码示例
-------------------------------------------------------

=== TEST 1: encrypt test
--- in chomp
abc
--- lua
m = require("mcrypt")
k = "abcdefgx"
iv = "529b57ba"
print(m.bf_cfb_en(k, iv, '<<in>>'))
--- chomp_got
--- out chomp base64_decode
zJYV


=== TEST 2: decrypt test
--- in chomp base64_decode
zJYV
--- lua
m = require("mcrypt")
k = "abcdefgx"
iv = "529b57ba"
print(m.bf_cfb_de(k, iv, '<<in>>'))
--- chomp_got
--- out chomp
abc


=== TEST 3: encrypt test error iv len
--- lua
m = require("mcrypt")
k = "abcdefgx"
iv = "529b57b"
print(m.bf_cfb_de(k, iv, ''))
--- chomp_got
--- err
error iv len


=== TEST 4: decrypt with short k <8-128>
--- lua
m = require("mcrypt")
k = 'abc'
iv = "529b57b"
print(m.bf_cfb_de(k, iv, ''))
--- chomp_got
--- err
error k len


=== TEST 4: decrypt with nil k
--- lua
m = require("mcrypt")
k = nil
iv = "529b57b"
print(m.bf_cfb_de(k, iv, ''))
--- chomp_got
--- err
bad argument #1 to 'bf_cfb_de' (string expected, got nil)


=== TEST 4: decrypt with nil iv
--- lua
m = require("mcrypt")
k = "abcdefgx"
iv = nil
print(m.bf_cfb_de(k, iv, ''))
--- chomp_got
--- err
bad argument #2 to 'bf_cfb_de' (string expected, got nil)


=== TEST 4: decrypt with nil value
--- lua
m = require("mcrypt")
k = "abcdefgx"
iv = "529b57ba"
print(m.bf_cfb_de(k, iv, nil))
--- chomp_got
--- err
bad argument #3 to 'bf_cfb_de' (string expected, got nil)


=== TEST 4: decrypt with empty string value
--- lua
m = require("mcrypt")
k = "abcdefgx"
iv = "529b57ba"
print('[' .. m.bf_cfb_de(k, iv, '') .. ']')
--- chomp_got
--- out chomp
[]
