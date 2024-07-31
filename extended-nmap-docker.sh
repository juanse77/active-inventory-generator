#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Use: $0 <nmap-parameters> <output-excel-file-name> <email-alert>"
    exit 1
fi

NMAP_PARAMS=$1
OUTPUT_FILE=$2
EMAIL_ALERT=$3

APP_DIR="/opt/active-inventory-generator"

docker build -t active-inventory-generator-img "$APP_DIR"
docker run --rm active-inventory-generator-img "$NMAP_PARAMS" "$OUTPUT_FILE" "$EMAIL_ALERT"

