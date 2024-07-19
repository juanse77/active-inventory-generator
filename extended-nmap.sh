#!/bin/bash

send_notice () {
    local _time=$(date +%s)
    local _time_formatted=$(date +"on %Y-%m-%d at %H:%M:%S")

    local _message="$1 in $NUC device $_time_formatted"
    curl -X POST -H "Content-type: application/json" --data "{'text':\"$_message\"}" $WEB_HOOK

    message=$_message
}

if [ $# -lt 3 ]; then
    echo "Use: $0 <nmap-parameters> <output-excel-file-name> <email-alert>"
    exit 1
fi

source /opt/active-inventory-generator/environment_vars.env
source /opt/active-inventory-generator/.env/bin/activate

NMAP_PARAMS=$1
OUTPUT_FILE=$2
EMAIL_ALERT=$3
SUBJECT="Nmap scan"
NUC=$(hostname)

XML_FILE=$(mktemp nmap_result.XXXXXX.xml)

start_time=$(date +%s)
start_time_formatted=$(date +"%H:%M")

send_notice "New nmap scan has been launched"

nmap $NMAP_PARAMS -oX $XML_FILE --stylesheet="https://svn.nmap.org/nmap/docs/nmap.xsl"

if [ $? -ne 0 ]; then    
    send_notice "Nmap running error"
    python send-report.py $EMAIL_ADDRESS $EMAIL_PASSWORD $EMAIL_ALERT $SUBJECT $message 
    exit 1
fi

send_notice "Nmap successfully finished"

python active-inventory-generator.py $XML_FILE $OUTPUT_FILE

if [ $? -ne 0 ]; then
    send_notice "Error in generating the Active Inventory report"
    python send-report.py $EMAIL_ADDRESS $EMAIL_PASSWORD $EMAIL_ALERT $SUBJECT $message
    exit 1
fi

# rm $XML_FILE # Activate when the script has been proved, if you wish

time_mark=$(date +"%Y%m%d%H%M%S")
ZIP_NAME="report-nmap-scan-$time_mark.zip"

zip $ZIP_NAME $OUTPUT_FILE $XML_FILE

send_notice "New Active Inventory report created"
python send-report.py --attachment "$ZIP_NAME" "$EMAIL_ADDRESS" "$EMAIL_PASSWORD" "$EMAIL_ALERT" "$SUBJECT" "$message"

deactivate