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

XSL_FILE="/opt/active-inventory-generator/nmap.xsl"

SUBJECT="Nmap scan"
NUC=$(hostname)

time_mark=$(date +"%Y%m%d%H%M%S")

XML_FILE="nmap_result-$time_mark.xml"
HTML_FILE="nmap_result-$time_mark.html"

start_time=$(date +%s)
start_time_formatted=$(date +"%H:%M")

send_notice "New nmap scan has been launched"

nmap $NMAP_PARAMS -oX $XML_FILE --stylesheet="https://svn.nmap.org/nmap/docs/nmap.xsl"

if [ $? -ne 0 ]; then    
    send_notice "Nmap running error"
    python /opt/active-inventory-generator/send-report.py "$EMAIL_ADDRESS" "$EMAIL_PASSWORD" "$EMAIL_ALERT" "$SUBJECT" "$message" 
    exit 1
fi

send_notice "Nmap successfully finished"

python /opt/active-inventory-generator/active-inventory-generator.py "$XML_FILE" "$OUTPUT_FILE"

if [ $? -ne 0 ]; then
    send_notice "Error in generating the Active Inventory report"
    python /opt/active-inventory-generator/send-report.py "$EMAIL_ADDRESS" "$EMAIL_PASSWORD" "$EMAIL_ALERT" "$SUBJECT" "$message"
    exit 1
fi

# rm $XML_FILE # Activate when the script has been proved, if you wish

python /opt/active-inventory-generator/xml-to-html.py "$XML_FILE" "$XSL_FILE" "$HTML_FILE"

time_mark=$(date +"%Y%m%d%H%M%S")
ZIP_NAME="report-nmap-scan-$time_mark.zip"

zip "$ZIP_NAME" "$OUTPUT_FILE" "$XML_FILE" "$HTML_FILE"

send_notice "New Active Inventory report created"
python /opt/active-inventory-generator/send-report.py --attachment "$ZIP_NAME" "$EMAIL_ADDRESS" "$EMAIL_PASSWORD" "$EMAIL_ALERT" "$SUBJECT" "$message"

deactivate