#!/bin/bash
# ==================================================================
step="install pcre openssl etc."

function checkStepStatus(){
	if [ 0 -ne "$?" ]; then  
		echo "$step failure..." 
		exit 1
	else
		echo "$step success..."
	fi
}

# ==================================================================

YOP_NGINX_INSTALL_DIR=`pwd`

echo "1.$step"
if ["" -eq `which yum`]; then
    # Debian 和 Ubuntu 用户
    apt-get update & apt-get upgrade
    apt-get install vim git unzip gcc perl libpcre3 libpcre3-dev openssl libssl-dev libreadline-gplv2-dev libncurses5-dev uuid-dev build-essential luajit
else
    # Fedora 和 RedHat 用户
    yum install -y pcre openssl readline-devel pcre-devel openssl-devel gcc libuuid libuuid-devel mcrypt libmcrypt-devel
fi

checkStepStatus

# ==================================================================

step="download dyups"
echo "2.$step"
cd "$YOP_NGINX_INSTALL_DIR"
git clone git://github.com/yzprofile/ngx_http_dyups_module.git || checkStepStatus

# ==================================================================

step="download and install openresty"
echo "3.$step"
cd "$YOP_NGINX_INSTALL_DIR"
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

checkStepStatus
make && make install || checkStepStatus
export PATH="$PATH:/usr/local/openresty/bin"

# ==================================================================

step="download and install luarocks"
echo "4.$step"
cd "$YOP_NGINX_INSTALL_DIR"
wget http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz
tar xzvf luarocks-2.3.0.tar.gz
cd luarocks-2.3.0
./configure \
  --lua-suffix=jit \
  --with-lua=/usr/local/openresty/luajit \
  --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1

checkStepStatus
make -j2 && make build && make install || checkStepStatus

# ==================================================================

step="download and install kong"
echo "5.$step"
cd "$YOP_NGINX_INSTALL_DIR"
git clone http://wenkang.zhang:Janeeyre1991@172.17.103.2/git/yop-nginx && git checkout master && luarocks install ./kong-0.8.3-0.rockspec || checkStepStatus

# ==================================================================

step="download and install codec"
echo "6.$step"
cd "$YOP_NGINX_INSTALL_DIR"
git clone https://github.com/yp-creative/yop-nginx-codec.git
cd yop-nginx-codec
make && make install || checkStepStatus

# ==================================================================

step="download and install mcrypt"
echo "7.$step"
cd "$YOP_NGINX_INSTALL_DIR"
git clone https://github.com/yp-creative/yop-nginx-mcrypt.git
cd yop-nginx-mcrypt
make && make install || checkStepStatus

# ==================================================================



