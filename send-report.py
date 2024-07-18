import smtplib
import argparse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(sender_email, sender_password, receiver_email, subject, body):
    try:
        smtp_server = "smtp.gmail.com"
        smtp_port = 587

        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = receiver_email
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)

        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()

        print(f"Email successfully sent to {receiver_email}")

    except Exception as e:
        print(f"Error: {e}")
        exit(1)

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Send an automatic email")
    parser.add_argument('sender_email', help="Sender email address")
    parser.add_argument('sender_password', help="Password of the sender's email account")
    parser.add_argument('receiver_email', help="Email address of recipient")
    parser.add_argument('subject', help="Email subject")
    parser.add_argument('body', help="Email body")

    args = parser.parse_args()

    send_email(args.sender_email, args.sender_password, args.receiver_email, args.subject, args.body)
