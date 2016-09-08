#!/bin/sh

# 1.安装pcre openssl等

if ["" -eq `which yum`]; then
    # Debian 和 Ubuntu 用户
    apt-get update & apt-get upgrade
    apt-get install vim git unzip gcc perl libpcre3 libpcre3-dev openssl libssl-dev libreadline-gplv2-dev libncurses5-dev uuid-dev build-essential luajit
else
    # Fedora 和 RedHat 用户
    sudo yum install -y pcre openssl readline-devel pcre-devel openssl-devel gcc libuuid libuuid-devel mcrypt libmcrypt-devel
fi

# 2.下载dyups

cd /opt
git clone git://github.com/yzprofile/ngx_http_dyups_module.git

# 4.下载并安装openresty
# --prefix=/usr/local/openresty 程序会被安装到/usr/local/openresty目录

wget http://openresty.org/download/ngx_openresty-1.9.15.1.tar.gz
tar xzvf ngx_openresty-1.9.15.1.tar.gz
cd openresty-1.9.15.1
./configure \
  --with-pcre-jit \
  --with-ipv6 \
  --with-http_realip_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --add-module=../ngx_http_dyups_module
make
make install

export PATH="$PATH:/usr/local/openresty/bin"

# 6.下载并安装luarocks

cd /opt
wget http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz
tar xzvf luarocks-2.3.0.tar.gz
cd luarocks-2.3.0
./configure \
  --lua-suffix=jit \
  --with-lua=/usr/local/openresty/luajit \
  --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1
make -j2
make build
make install

# 7.

cd /opt
curl https://raw.githubusercontent.com/yp-creative/kong/develop/kong-0.8.3-0.rockspec > /usr/local/kong/plugins/kong-0.8.3-0.rockspec
curl https://raw.githubusercontent.com/yp-creative/kong/develop/kong-custom-plugins-0.8.3-0.rockspec > /usr/local/kong/plugins/kong-custom-plugins-0.8.3-0.rockspec

luarocks install ./kong-0.8.3-0.rockspec
luarocks install ./kong-custom-plugins-0.8.3-0.rockspec
