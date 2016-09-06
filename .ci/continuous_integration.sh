#!/bin/sh
echo '1.kong continuous integration start...'

echo "2.check if we need to update the rockspec file:$1"

# TODO why?
# git archive --remote=http://baitao.ji@172.17.103.2/git/yop-nginx/ HEAD kong-custom-plugins-latest.rockspec
# fatal: Operation not supported by protocol.
if [ $1 != "false" ]; then
	echo '3.checkout latest kong-customer-plugins-latest.rockspec...'
	#curl http://172.17.103.2/git/yop-nginx/kong-custom-plugins-latest.rockspec > /usr/local/kong/plugins/kong-custom-plugins-latest.rockspec
	git clone http://172.17.103.2/git/yop-nginx/
	cd yop-nginx/
	git checkout origin/develop
	cp kong-custom-plugins-latest.rockspec ..
	rm -Rf yop-nginx/
else
	echo '3.there is no need to update the rock spec file,skip it...'
fi

echo '4.install latest kong-custom-plugins using luarocks...'
cd /usr/local/kong/plugins/
echo 'Zj4xyBkgjd'| sudo -S /usr/local/bin/luarocks install kong-custom-plugins-latest.rockspec

echo '5.restart kong...'
echo 'Zj4xyBkgjd'| sudo -S /usr/local/bin/kong stop
echo 'Zj4xyBkgjd'| sudo -S /usr/local/bin/kong start
