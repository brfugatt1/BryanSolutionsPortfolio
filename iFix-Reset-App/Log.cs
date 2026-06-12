using System;
using System.Configuration;
using System.IO;

public static class Log
{
    public static void Write(string message)
    {
        try
        {
            var path = ConfigurationManager.AppSettings["LogPath"];
            if (string.IsNullOrWhiteSpace(path)) return;

            var dir = Path.GetDirectoryName(path);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            var line = "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] " + message;
            File.AppendAllText(path, line + Environment.NewLine);
        }
        catch { /* logging must never crash the app */ }
    }
}
