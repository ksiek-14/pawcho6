#!/bin/sh
IP=$(hostname -i | awk "{print \$1}")
HOST=$(hostname)
sed -i "s~IP_PLACEHOLDER~${IP}~g" /usr/share/nginx/html/index.html
sed -i "s~HOST_PLACEHOLDER~${HOST}~g" /usr/share/nginx/html/index.html
sed -i "s~VERSION_PLACEHOLDER~${APP_VERSION}~g" /usr/share/nginx/html/index.html
exec nginx -g "daemon off;"
