#!/bin/sh
cd /usr/local/kong/logs
today=`date +%Y-%m-%d`
mv error.log "error.$today.log"
/usr/local/bin/kong reload