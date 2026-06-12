using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;

public partial class _Default : System.Web.UI.Page
{
    private string name = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        name = (Context != null && Context.User != null && Context.User.Identity != null)
            ? Context.User.Identity.Name
            : "";
        litUser.Text = string.IsNullOrEmpty(name) ? "(anonymous)" : name;

        if (!IsPostBack)
        {
            litResult.Text = "";
            try { CleanupOldUploads(30); } catch { }
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        var area = (ddlArea.SelectedValue ?? "").Trim();

        var machines = Request.Form.GetValues("machine[]") ?? new string[0];
        var reasons  = Request.Form.GetValues("reason[]")  ?? new string[0];

        if (string.IsNullOrWhiteSpace(area))
        {
            Fail("Please select an area.");
            return;
        }

        var items = new List<Tuple<string, string>>();
        int n = Math.Max(machines.Length, reasons.Length);
        for (int i = 0; i < n; i++)
        {
            var m = (i < machines.Length ? (machines[i] ?? "").Trim() : "");
            var r = (i < reasons.Length  ? (reasons[i]  ?? "").Trim() : "");
            if (!string.IsNullOrEmpty(m) && !string.IsNullOrEmpty(r))
                items.Add(Tuple.Create(m, r));
        }

        if (items.Count == 0)
        {
            Fail("Please enter at least one Machine and Description.");
            return;
        }

        if (items.Count > 20)
        {
            Fail("Too many screens in one request.");
            return;
        }

        // --- Save per-screen photos ---
        var photoUrls = new List<string>();
        for (int i = 0; i < items.Count; i++)
            photoUrls.Add(null);

        var allFiles = Request.Files;
        for (int fi = 0; fi < allFiles.Count; fi++)
        {
            var key = allFiles.GetKey(fi);
            if (key != "photo[]") continue;

            var file = allFiles[fi];
            if (file == null || file.ContentLength == 0) continue;

            int screenIdx = 0;
            int photoCount = 0;
            for (int k = 0; k < fi; k++)
                if (allFiles.GetKey(k) == "photo[]") photoCount++;
            screenIdx = photoCount;

            if (screenIdx >= items.Count) continue;

            try
            {
                const int MAX_BYTES = 5 * 1024 * 1024;
                if (file.ContentLength > MAX_BYTES)
                    throw new Exception("Image too large (max 5MB).");

                var ct = (file.ContentType ?? "").ToLowerInvariant();
                if (!ct.StartsWith("image/"))
                    throw new Exception("Only images are allowed.");

                var datePart = DateTime.Now.ToString("yyyyMMdd");
                var physicalRoot = Server.MapPath("~/App_Data/uploads/" + datePart + "/");
                if (!Directory.Exists(physicalRoot)) Directory.CreateDirectory(physicalRoot);

                var ext = Path.GetExtension(file.FileName);
                if (string.IsNullOrEmpty(ext)) ext = ".jpg";
                var fname = Guid.NewGuid().ToString("N") + ext;

                file.SaveAs(Path.Combine(physicalRoot, fname));

                var baseUrl = Request.Url.GetLeftPart(UriPartial.Authority);
                var link = ResolveUrl("Photo.ashx?d=" + datePart + "&n=" + fname);
                photoUrls[screenIdx] = baseUrl + link;
            }
            catch (Exception ex)
            {
                SafeLog("Photo upload error (screen " + (screenIdx + 1) + "): " + ex.Message);
            }
        }

        var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm");

        // --- Build plain text for log ---
        var plain = new StringBuilder();
        plain.Append("iFix Reset Request\r\n\r\n");
        plain.Append("Area: ").Append(area).Append("\r\n\r\n");
        for (int i = 0; i < items.Count; i++)
        {
            plain.Append("Screen ").Append(i + 1).Append(":\r\n");
            plain.Append("  Machine: ").Append(items[i].Item1).Append("\r\n");
            plain.Append("  Description: ").Append(items[i].Item2).Append("\r\n");
            if (!string.IsNullOrEmpty(photoUrls[i]))
                plain.Append("  Photo: ").Append(photoUrls[i]).Append("\r\n");
            plain.Append("\r\n");
        }
        plain.Append("Requested by: ").Append(name).Append("\r\n");
        plain.Append("When: ").Append(timestamp);

        // --- Build HTML email ---
        var html = new StringBuilder();
        html.Append("<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>");
        html.Append("<html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1'></head>");
        html.Append("<body style='margin:0;padding:0;background-color:#111111;'>");
        html.Append("<table width='100%' cellspacing='0' cellpadding='0' style='border-collapse:collapse;background-color:#111111;'><tr><td align='center' style='padding:30px 20px;'>");
        html.Append("<table width='600' cellspacing='0' cellpadding='0' style='border-collapse:collapse;background-color:#1e1e1e;border:1px solid #333;max-width:600px;'>");

        // Header
        html.Append("<tr><td align='center' style='padding:50px 40px 40px 40px;background-color:#1e1e1e;'>");
        html.Append("<h1 style='margin:0;font-family:arial,helvetica,sans-serif;font-size:30px;font-weight:normal;color:#ffffff;letter-spacing:0.5px;'>iFix Reset Request</h1>");
        html.Append("</td></tr>");

        // Accent divider
        html.Append("<tr><td style='height:3px;background-color:#E87722;font-size:0;line-height:0;'>&nbsp;</td></tr>");

        // Area
        html.Append("<tr><td align='center' style='padding:40px 40px 30px 40px;background-color:#2a2a2a;'>");
        html.Append("<p style='margin:0 0 10px 0;font-family:arial,helvetica,sans-serif;font-size:12px;color:#999999;text-transform:uppercase;letter-spacing:1.5px;'>Area</p>");
        html.Append("<p style='margin:0;font-family:arial,helvetica,sans-serif;font-size:20px;color:#ffffff;'>").Append(HttpUtility.HtmlEncode(area)).Append("</p>");
        html.Append("</td></tr>");

        // Screen cards
        for (int i = 0; i < items.Count; i++)
        {
            var isLast = (i == items.Count - 1);
            var bottomPad = isLast ? "30px" : "12px";
            html.Append("<tr><td style='padding:").Append(i == 0 ? "24px" : "0").Append(" 40px ").Append(bottomPad).Append(" 40px;background-color:#2a2a2a;'>");
            html.Append("<table width='100%' cellspacing='0' cellpadding='0' style='border-collapse:collapse;background-color:#1e1e1e;border:1px solid #444;border-radius:4px;'>");

            html.Append("<tr><td align='center' style='padding:24px 24px 0 24px;'>");
            html.Append("<p style='margin:0;font-family:arial,helvetica,sans-serif;font-size:11px;color:#E87722;text-transform:uppercase;letter-spacing:1.5px;'>Screen ").Append(i + 1).Append("</p>");
            html.Append("</td></tr>");

            html.Append("<tr><td align='center' style='padding:20px 24px 0 24px;'>");
            html.Append("<p style='margin:0 0 6px 0;font-family:arial,helvetica,sans-serif;font-size:12px;color:#999999;text-transform:uppercase;letter-spacing:1px;'>Machine</p>");
            html.Append("<p style='margin:0;font-family:arial,helvetica,sans-serif;font-size:16px;color:#ffffff;'>").Append(HttpUtility.HtmlEncode(items[i].Item1)).Append("</p>");
            html.Append("</td></tr>");

            html.Append("<tr><td align='center' style='padding:20px 24px ").Append(string.IsNullOrEmpty(photoUrls[i]) ? "24px" : "16px").Append(" 24px;'>");
            html.Append("<p style='margin:0 0 6px 0;font-family:arial,helvetica,sans-serif;font-size:12px;color:#999999;text-transform:uppercase;letter-spacing:1px;'>Description</p>");
            html.Append("<p style='margin:0;font-family:arial,helvetica,sans-serif;font-size:16px;color:#ffffff;'>").Append(HttpUtility.HtmlEncode(items[i].Item2)).Append("</p>");
            html.Append("</td></tr>");

            if (!string.IsNullOrEmpty(photoUrls[i]))
            {
                html.Append("<tr><td align='center' style='padding:0 24px 24px 24px;'>");
                html.Append("<a href='").Append(photoUrls[i]).Append("' style='font-family:arial,helvetica,sans-serif;font-size:13px;color:#E87722;text-decoration:none;border:1px solid #E87722;border-radius:4px;padding:6px 16px;display:inline-block;'>View Photo</a>");
                html.Append("</td></tr>");
            }

            html.Append("</table></td></tr>");
        }

        // Footer info
        html.Append("<tr><td align='center' style='padding:30px 40px 40px 40px;background-color:#1e1e1e;'>");
        html.Append("<p style='margin:0 0 12px 0;font-family:arial,helvetica,sans-serif;font-size:13px;color:#cccccc;'>");
        html.Append("<span style='color:#999999;'>Requested by&nbsp;&nbsp;</span>").Append(HttpUtility.HtmlEncode(name)).Append("</p>");
        html.Append("<p style='margin:0;font-family:arial,helvetica,sans-serif;font-size:13px;color:#cccccc;'>");
        html.Append("<span style='color:#999999;'>When&nbsp;&nbsp;</span>").Append(timestamp).Append("</p>");
        html.Append("</td></tr>");

        // Bottom bar
        html.Append("<tr><td align='center' style='padding:20px 40px;background-color:#111111;border-top:1px solid #333;'>");
        html.Append("<p style='margin:0;font-family:arial,helvetica,sans-serif;font-size:11px;color:#555555;'>This is an automated notification from the iFix Reset Request system.</p>");
        html.Append("</td></tr>");

        html.Append("</table></td></tr></table></body></html>");

        string err;
        var ok = SendNotification(html.ToString(), plain.ToString(), out err);

        if (ok)
        {
            Response.Redirect("Success.aspx", endResponse: false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        Fail("Failed to send. " + (err ?? "No channels configured."));
    }

    private bool SendNotification(string htmlBody, string plainBody, out string error)
    {
        error = null;
        var sent = false;

        // Teams webhook (optional — leave TeamsWebhookUrl empty to disable)
        try
        {
            var webhook = ConfigurationManager.AppSettings["TeamsWebhookUrl"];
            if (!string.IsNullOrWhiteSpace(webhook))
            {
                SendToTeams(webhook, plainBody);
                sent = true;
            }
        }
        catch (Exception ex)
        {
            error = AddError(error, "Teams: " + ex.Message);
        }

        // SMTP email
        try
        {
            var host = ConfigurationManager.AppSettings["SmtpHost"];
            if (!string.IsNullOrWhiteSpace(host))
            {
                int port = 25;
                int.TryParse(ConfigurationManager.AppSettings["SmtpPort"], out port);
                var from = ConfigurationManager.AppSettings["SmtpFrom"];
                var to   = ConfigurationManager.AppSettings["SmtpTo"];
                SendEmail(host, port, from, to, "iFix Reset Request", htmlBody);
                sent = true;
            }
        }
        catch (Exception ex)
        {
            var detail = (ex.InnerException != null ? " | " + ex.InnerException.Message : "");
            error = AddError(error, "SMTP: " + ex.Message + detail);
        }

        // Server-side log
        try
        {
            var logPath = ConfigurationManager.AppSettings["LogPath"];
            if (!string.IsNullOrWhiteSpace(logPath))
            {
                var logLine = "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "]" + Environment.NewLine
                            + plainBody
                            + "sent=" + sent + Environment.NewLine
                            + "----------------------------------------" + Environment.NewLine;
                File.AppendAllText(logPath, logLine, Encoding.UTF8);
            }
        }
        catch { }

        return sent;
    }

    private void SendEmail(string host, int port, string from, string to, string subject, string htmlBody)
    {
        using (var msg = new MailMessage())
        {
            msg.From = new MailAddress(from, "iFix Reset");
            msg.To.Add(to);
            msg.Subject = subject;
            msg.Body = htmlBody;
            msg.IsBodyHtml = true;
            msg.BodyEncoding = Encoding.UTF8;
            msg.SubjectEncoding = Encoding.UTF8;

            using (var smtp = new SmtpClient(host, port))
            {
                bool enableSsl = false, useDefaultCreds = false;
                bool.TryParse(ConfigurationManager.AppSettings["SmtpEnableSsl"], out enableSsl);
                bool.TryParse(ConfigurationManager.AppSettings["SmtpUseDefaultCredentials"], out useDefaultCreds);

                smtp.EnableSsl = enableSsl;
                smtp.UseDefaultCredentials = useDefaultCreds;

                var smtpUser = ConfigurationManager.AppSettings["SmtpUser"];
                var smtpPass = ConfigurationManager.AppSettings["SmtpPass"];
                if (!useDefaultCreds && !string.IsNullOrEmpty(smtpUser))
                    smtp.Credentials = new NetworkCredential(smtpUser, smtpPass ?? "");

                smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                smtp.Send(msg);
            }
        }
    }

    private void SendToTeams(string webhookUrl, string text)
    {
        ServicePointManager.SecurityProtocol =
            SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;

        var payload = "{\"text\":\"" + text.Replace("\\", "\\\\").Replace("\"", "\\\"")
                                          .Replace("\r", "\\r").Replace("\n", "\\n") + "\"}";
        var bytes = Encoding.UTF8.GetBytes(payload);

        var req = (HttpWebRequest)WebRequest.Create(webhookUrl);
        req.Method = "POST";
        req.ContentType = "application/json; charset=utf-8";
        req.ContentLength = bytes.Length;

        using (var s = req.GetRequestStream()) { s.Write(bytes, 0, bytes.Length); }
        using (var resp = (HttpWebResponse)req.GetResponse())
        {
            if (resp.StatusCode != HttpStatusCode.OK)
                throw new Exception("Teams webhook failed: " + (int)resp.StatusCode);
        }
    }

    private string AddError(string existing, string add)
    {
        return string.IsNullOrEmpty(existing) ? add : (existing + " | " + add);
    }

    private void Fail(string message)
    {
        btnSubmit.Enabled = true;
        btnSubmit.Text = "Send Request";
        litResult.Text = "<div class='error'>" + HttpUtility.HtmlEncode(message) + "</div>";
        ClientScript.RegisterStartupScript(this.GetType(), "unlock", "window.__ifix_sending=false;", true);
    }

    private void CleanupOldUploads(int keepDays)
    {
        var root = Server.MapPath("~/App_Data/uploads");
        if (!Directory.Exists(root)) return;

        foreach (var dir in Directory.GetDirectories(root))
        {
            var name = Path.GetFileName(dir);
            DateTime dt;
            if (DateTime.TryParseExact(name, "yyyyMMdd", null,
                System.Globalization.DateTimeStyles.None, out dt))
            {
                if (dt < DateTime.Today.AddDays(-keepDays))
                {
                    try { Directory.Delete(dir, true); } catch { }
                }
            }
        }
    }

    private void SafeLog(string message)
    {
        try { System.Diagnostics.Trace.WriteLine("[ifix-reset] " + message); } catch { }
    }
}
