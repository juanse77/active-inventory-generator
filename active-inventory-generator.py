import sys
import xml.etree.ElementTree as ET
import pandas as pd

def get_info_vuln(node, port="unkown", service="unknown"):
    vuln_cve = []
    vulnerabilities = []

    elem = node.find("table")

    if elem:

        cves = elem.find(".//table[@key='ids']") if elem is not None else None

        if cves is not None:
            for cve in cves.findall('elem'):
                vuln_cve.append(cve.text)

        info = {
            "title": elem.find(".//elem[@key='title']").text,
            "state": elem.find(".//elem[@key='state']").text,
            "description": elem.find(".//table[@key='description']/elem").text,
            "disclosure_date": elem.find(".//elem[@key='disclosure']").text if elem.find(".//elem[@key='disclosure']") is not None else 'unknown',
            "references": [e.text for e in elem.findall(".//table[@key='refs']/elem")]
        }

        vulnerabilities.append({
            'port': port,
            'service': service,
            'name': info.get('title'),
            'description': info.get('description'),
            'disclosure_date': info.get('disclosure_date'),
            'references': info.get('references'),
            'cve': vuln_cve
        })

    return vulnerabilities

def extract_host_info(host):
    ip = host.find('address').attrib['addr']
    ports = []
    vulnerabilities = []

    for port in host.find('ports').findall('port'):
        port_id = port.attrib['portid']
        service_node = port.find('service')
        service = service_node.attrib.get('name', 'unknown') if service_node is not None else 'unknown'
        ports.append((port_id, service))

        for script in port.findall('script'):
            if 'vulnerable' in script.attrib['output'].lower():
                vulnerabilities.extend(get_info_vuln(script, port_id, service))
                
    hostscript = host.find('hostscript')
    if hostscript is not None:
        for script in hostscript.findall('script'):
            if 'vulnerable' in script.attrib['output'].lower():
                vulnerabilities.extend(get_info_vuln(script))

    return ip, ports, vulnerabilities

def main(xml_file, xlsx_file_name):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    hosts_info = []
    for host in root.findall('host'):
        ip, ports, vulnerabilities = extract_host_info(host)
        hosts_info.append({
            'ip': ip,
            'ports': ports,
            'vulnerabilities': vulnerabilities
        })

    for host_info in hosts_info:
        print(f"IP Direction: {host_info['ip']}")
        print("Ports and Services:")
        for port, service in host_info['ports']:
            print(f"  - Port: {port}, Service: {service}")
        print("Vulnerabilities:")
        for vuln in host_info['vulnerabilities']:
            print(f"  - Port: {vuln['port']}, Service: {vuln['service']}")
            print(f"    Name: {vuln['name']}")
            print(f"    {', '.join(vuln['cve'])}")
            print(f"    Disclosure date: {vuln['disclosure_date']}")
            print(f"    References: {', '.join(vuln['references'])}")
            print(f"    Description: {vuln['description']}")
            
        print("\n")

    ips = []
    vulns = []
    for host_info in hosts_info:
        puertos_servicios = []
        vuls = []

        ips.append(host_info['ip'])
        for port, service in host_info['ports']:
            puertos_servicios.append(f"  - Port: {port}, Service: {service}git")    
    
        puertos_servicios  = "\n".join(puertos_servicios)

        for vuln in host_info['vulnerabilities']:
            v = f"  - Port: {vuln['port']}, Service: {vuln['service']}\n"
            v += f"    Name: {vuln['name']}\n"
            v += f"    {', '.join(vuln['cve'])}\n"
            #v += f"    Disclosure Date: {vuln['disclosure_date']}\n"
            v += f"    References: \n\t{'\n\t'.join(vuln['references'])}\n"
            #v += f"    Description: {vuln['description']}\n"

            vuls.append(v)

        vulns.append("\n".join(vuls))

    datos = {
        "IP Direction": ips,
        "Ports and Services": puertos_servicios,
        "Vulnerabilities": vulns
    }

    df = pd.DataFrame(datos)
    
    if not xlsx_file_name.endWith('.xlsx'):
        xlsx_file_name = f"{xlsx_file_name}.xlsx"

    df.to_excel(xlsx_file_name, sheet_name="Actives Inventary", index=False)

    print("An excel file has been generated with the results\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Use: python active-inventory-generator.py <xml-file> <xlsx-file-nam>")
        sys.exit(1)

    xml_file = sys.argv[1]
    xlsx_file_name = sys.argv[2]
    main(xml_file, xlsx_file_name)
