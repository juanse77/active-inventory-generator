import lxml.etree as ET
import argparse

def main(xml_file, xsl_file, html_output):

    xml_tree = ET.parse(xml_file)
    xsl_tree = ET.parse(xsl_file)

    transform = ET.XSLT(xsl_tree)
    html_tree = transform(xml_tree)

    with open(html_output, 'wb') as f:
        f.write(ET.tostring(html_tree, pretty_print=True, method="html"))

    print(f"\nHTML file generated: {html_output}")

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Translate XML file to valid HTML document")
    parser.add_argument('xml_file_path', help="Path of the XML file to translate to HTML")
    parser.add_argument('xsl_file_path', help="Stylesheet for the XML file")
    parser.add_argument('html_file_name', help="Filename of the HTML to generate")

    args = parser.parse_args()

    main(args.xml_file_path, args.xsl_file_path, args.html_file_name)
