import smtplib
import argparse
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import os

def send_email(from_email, app_password, to_email, subject, body, attachment_path=None):

    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    if attachment_path:
        try:
            filename = os.path.basename(attachment_path)
            attachment = open(attachment_path, "rb")
            
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(attachment.read())
            encoders.encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename= {filename}')
            
            msg.attach(part)
            attachment.close()
    
        except Exception as e:
            print(f"Could not attach file: {e}")
            return

    try:
        
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(from_email, app_password)
        text = msg.as_string()
        server.sendmail(from_email, to_email.split(","), text)
        server.quit()

        print(f"\nEmail sent to {to_email}")

    except Exception as e:
        print(f"\nError: {e}")


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Send an automatic email")
    parser.add_argument('sender_email', help="Sender email address")
    parser.add_argument('sender_password', help="Password of the sender's email account")
    parser.add_argument('receiver_email', help="Email address of recipient")
    parser.add_argument('subject', help="Email subject")
    parser.add_argument('body', help="Email body")
    parser.add_argument('--attachment', help="Path to attached file", default=None)

    args = parser.parse_args()

    send_email(args.sender_email, args.sender_password, args.receiver_email, args.subject, args.body, args.attachment)
