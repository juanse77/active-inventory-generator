#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Use: $0 <nmap-parameters> <output-excel-file-name>"
    exit 1
fi

NMAP_PARAMS=$1
OUTPUT_FILE=$2

XML_FILE=$(mktemp nmap_result.XXXXXX.xml)

nmap $NMAP_PARAMS -oX $XML_FILE

if [ $? -ne 0 ]; then
    echo "Error when running nmap"
    exit 1
fi

python active-inventory-generator.py $XML_FILE $OUTPUT_FILE

if [ $? -ne 0 ]; then
    echo "Error in generating the Excel file"
    exit 1
fi

# rm $XML_FILE # Activate when the script has been proved, if you wish

echo "Excel file generated: $OUTPUT_FILE"

