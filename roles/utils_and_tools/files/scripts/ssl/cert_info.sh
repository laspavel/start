#!/bin/bash

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <certificate.pem>"
    exit 1
fi

CERT=$1

# Вывод полной информации о сертификате
openssl x509 -in "$CERT" -text -noout
