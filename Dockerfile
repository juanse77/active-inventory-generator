FROM ubuntu:24.04

RUN apt-get update
RUN apt-get install -y nmap bash curl zip dos2unix python3 python3-pip virtualenv

RUN mkdir -p /opt/active-inventory-generator
WORKDIR /opt/active-inventory-generator

RUN python3 -m virtualenv .env

COPY requirements.txt /opt/active-inventory-generator/
RUN /bin/bash -c "source /opt/active-inventory-generator/.env/bin/activate && pip install --no-cache-dir -r requirements.txt"

COPY nmap.xsl LICENSE.txt active-inventory-generator.py send-report.py xml-to-html.py environment_vars.env extended-nmap.sh /opt/active-inventory-generator/

RUN chmod +x extended-nmap.sh
RUN dos2unix environment_vars.env

ENTRYPOINT ["/opt/active-inventory-generator/extended-nmap.sh"]

