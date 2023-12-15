#!/bin/bash

CERT_DEFAULT_EMAIL=laspavel@gmail.com
CERT_DEFAULT_WEBROOT=/usr/share/nginx/html

certbot certonly --email $CERT_DEFAULT_EMAIL --webroot -w $CERT_DEFAULT_WEBROOT --agree-tos --keep --expand -d $1