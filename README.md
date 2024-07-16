# Active Inventory Generator:
Script designed to generate a report from the nmap execution results. Specifically, the information from the output in nmap XML format is filtered to dump the vulnerabilities found in the scanned network into an Excel file.

## How to use:
### Instalation:
It is recommended to create a virtual environment for installing the script dependencies. A quick way to create a virtual environment can be to use the 'virtualenv' command. Example of use:

> python -m virtualenv .env

This will create a virtual environment in the '.env' subfolder. Next, the environment must be activated by executing the command:

> .\\.env\Script\activate # en Windows

> source ./.env/bin/activate # en Linux

Next, you must install the script dependencies, executing:

> python -m pip install -r requirements.txt

With this initial configuration you are now ready to run the application.

### Running the application:

Running the application is as simple as launching the python script by calling the interpreter and passing it an XML file with the results of an nmap scan. For example, as follows:

> python active-inventory-generator.py scanned-network.xml excel-file-name.xlsx

You can also run the application through the 'extended-nmap.sh' script. This script will execute the nmap command and then execute the filter script for the xml document generated in the previous execution. To do this you must give execution permissions to the script, and pass it the parameters that you want nmap to take and then the name of the excel file that will be generated if all goes well.

> sudo chmod +x extended-nmap.sh

> ./extended-nmap.sh "-Pn -sCV --script vuln --top-ports -iL stored-ips" excel-file-name.xlsx

Once the execution is complete, an excel file should have been generated in the same folder from where the script was executed.



