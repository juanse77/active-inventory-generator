#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Uso: $0 <parámetros nmap> <archivo de salida>"
    exit 1
fi

NMAP_PARAMS=$1
OUTPUT_FILE=$2

XML_FILE=$(mktemp /tmp/nmap_result.XXXXXX.xml)

nmap $NMAP_PARAMS -oX $XML_FILE

if [ $? -ne 0 ]; then
    echo "Error al ejecutar nmap"
    exit 1
fi

python3 active-inventory-generator.py $XML_FILE $OUTPUT_FILE

if [ $? -ne 0 ]; then
    echo "Error in generating the Excel file"
    exit 1
fi

# rm $XML_FILE # Activate when the script has been proved, if you wish

echo "Excel file generated: $OUTPUT_FILE"
