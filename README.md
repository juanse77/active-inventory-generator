# Active Inventory Generator:
Script designed to generate a report from the nmap execution results. Specifically, the information from the output in nmap XML format is filtered to dump the vulnerabilities found in the scanned network into an Excel file.

## How to use:
### Instalation:
Firstly, clone the repository in the /opt folder, then you have to change to /opt/active-inventory-generator to continue the instalation. Before that, it is recommended to create a virtual environment for installing the script dependencies. A quick way to create a virtual environment can be to use the 'virtualenv' command. Example of use:

```bash
python -m virtualenv .env
```

This will create a virtual environment in the '.env' subfolder. Next, the environment must be activated by executing the command:

```bash
source ./.env/bin/activate # in Linux
```

Next, you must install the script dependencies, executing:

```bash
python -m pip install -r requirements.txt
```

For complete installation, you need to edit the ~/.bashrc in shell bash or ~/.zshrc to add the application folder to the PATH. Insert this line to the file:

```bash
export PATH=$PATH:/opt/active-inventory-generator
```

You must run this command to activate the change if you just added the line. This will not be necessary on subsequent system reboots.

```bash
source ~/.bashrc # in shell bash
or
source ~/.zshrc # in shell zsh
```

With this initial configuration you are now ready to run the application.

### Running the application:

Running the application is as simple as launching the python script by calling the interpreter and passing it an XML file with the results of an nmap scan. For example, as follows:

```bash
python active-inventory-generator.py scanned-network.xml excel-file-name.xlsx
```
## Running with integrated Nmap:

You can also run the application through the 'extended-nmap.sh' script. This script will execute the nmap command and then the filter script for the xml document generated in the same execution. To do this you must give execution permissions to the script, and pass it the parameters that you want Nmap to take like input, followed by the name of the excel file that will be generated if all goes well.

```bash
sudo chmod +x extended-nmap.sh

# If you are in the application folder and/or the application folder is not in the PATH
./extended-nmap.sh "-Pn -sCV --script vuln --top-ports 100 -iL stored-ips" excel-file-name.xlsx

# If the application folder is in the PATH
extended-nmap.sh "-Pn -sCV --script vuln --top-ports 100 -iL stored-ips" excel-file-name.xlsx
```

Once the execution is complete, an excel file should have been generated in the same folder from where the script was executed.

## New utilities added in version 2:

A shell bash script has been modified for sending alerts during the squential executing of nmap and the active inventory generator steps. During the progress of the execution messages to Slack and emails addresses will be sent.

## How to use:

For it to work, is necesary to have a valid file with three environment vars: EMAIL_ADDRESS, EMAIL_PASSWORD, and WEB_HOOK. EMAIL_ADDRESS and EMAIL_PASSWORD, have to define a valid Gmail email and its application password of sixteen characters. The WEB_HOOK variable is an URL for the channel of Slack to be publicated. For the script to be excuted you need to pass the paramenters of the nmap that will be used, the name of the excel file that will be created, and the email or the list of emails you want to send the generated excel file. For example:

```bash
./extended-nmap.sh "-Pn -sCV --script vuln --top-ports 100 -iL stored-ips" excel-file-name.xlsx recipient1@domain.com,recipient2@domain.com,recipient3@domain.com
```

The environment variables will be read from a file called 'environment_vars.env'. An example of that file could be like this:

```bash
export EMAIL_ADDRESS="user-company@gmail.com"
export EMAIL_PASSWORD="xndermtiocnduyrm"
export WEB_HOOK="https://hooks.slack.com/services/XXXXXXX/XXXXX/XXXX" 
```


