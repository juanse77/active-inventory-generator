#!/bin/bash

send_notice () {
    local _time=$(date +%s)
    local _time_formatted=$(date +"on %Y-%m-%d at %H:%M:%S")

    local _message="$1 in $NUC device $_time_formatted"
    curl -X POST -H "Content-type: application/json" --data "{'text':\"$_message\"}" $WEB_HOOK

    return $_message
}

if [ $# -lt 3 ]; then
    echo "Use: $0 <nmap-parameters> <output-excel-file-name> <email-alert>"
    exit 1
fi

source ./environment_vars.env

NMAP_PARAMS=$1
OUTPUT_FILE=$2
EMAIL_ALERT=$3
NUC=$(hostname)

XML_FILE=$(mktemp nmap_result.XXXXXX.xml)

start_time=$(date +%s)
start_time_formatted=$(date +"%H:%M")

send_notice("New nmap scan has been launched")

nmap $NMAP_PARAMS -oX $XML_FILE

if [ $? -ne 0 ]; then    
    python send-report.py $EMAIL_ADDRESS $EMAIL_PASSWORD $EMAIL_ALERT $SUBJECT send_notice("Nmap running error")
    exit 1
else
    send_notice("Nmap successfully finished")
fi

python active-inventory-generator.py $XML_FILE $OUTPUT_FILE

SUBJECT="Nmap scan"

if [ $? -ne 0 ]; then
    python send-report.py $EMAIL_ADDRESS $EMAIL_PASSWORD $EMAIL_ALERT $SUBJECT send_notice("Error in generating the Active Inventory report")
    exit 1
fi

# rm $XML_FILE # Activate when the script has been proved, if you wish

python send-report.py $EMAIL_ADDRESS $EMAIL_PASSWORD $EMAIL_ALERT $SUBJECT send_notice("New Active Inventory report created")


