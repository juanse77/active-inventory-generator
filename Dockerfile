FROM python:3.9.19-alpine3.20

RUN apk update

RUN apk add nmap
RUN apk add bash

RUN apk add curl
RUN apk add zip

RUN apk add --no-cache dos2unix

RUN mkdir -p /opt/active-inventory-generator

WORKDIR /opt/active-inventory-generator

RUN pip install virtualenv
RUN python -m virtualenv .env

COPY requirements.txt /opt/active-inventory-generator/

RUN /bin/bash -c "source /opt/active-inventory-generator/.env/bin/activate && pip install --no-cache-dir -r requirements.txt"

COPY nmap.xsl /opt/active-inventory-generator/
COPY LICENSE.txt /opt/active-inventory-generator/

COPY active-inventory-generator.py /opt/active-inventory-generator/
COPY send-report.py /opt/active-inventory-generator/
COPY xml-to-html.py /opt/active-inventory-generator/

COPY environment_vars.env /opt/active-inventory-generator/
COPY extended-nmap.sh /opt/active-inventory-generator/

RUN chmod +x extended-nmap.sh
RUN dos2unix environment_vars.env

ENTRYPOINT ["/opt/active-inventory-generator/extended-nmap.sh"]
