using System.Net;
using System.Net.Mail;
using System.Configuration;
using System.Text;

public static class MailClient
{
    public static void Send(string host, int port, string from, string to, string subject, string body)
    {
        using (var msg = new MailMessage())
        {
            msg.From = new MailAddress(from);
            msg.To.Add(to);
            msg.Subject = subject;
            msg.IsBodyHtml = false;

            // Explicitly set UTF-8 so bullet points and special chars render correctly
            msg.Body = body;
            msg.BodyEncoding = Encoding.UTF8;
            msg.SubjectEncoding = Encoding.UTF8;

            using (var smtp = new SmtpClient(host, port))
            {
                bool enableSsl = false, useDefaultCreds = false;
                bool.TryParse(ConfigurationManager.AppSettings["SmtpEnableSsl"], out enableSsl);
                bool.TryParse(ConfigurationManager.AppSettings["SmtpUseDefaultCredentials"], out useDefaultCreds);

                smtp.EnableSsl = enableSsl;
                smtp.UseDefaultCredentials = useDefaultCreds;

                var user = ConfigurationManager.AppSettings["SmtpUser"];
                var pass = ConfigurationManager.AppSettings["SmtpPass"];
                if (!useDefaultCreds && !string.IsNullOrEmpty(user))
                    smtp.Credentials = new NetworkCredential(user, pass ?? "");

                smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                smtp.Send(msg);
            }
        }
    }
}
