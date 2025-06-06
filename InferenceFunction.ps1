# 推論の例

# main処理 function

. ./WriteParametersFunction.ps1

function Inference {
  param(
    [string]$dummy
    ,[string]$prompt
    ,[int]$n_predict
    ,[string]$Uri
    ,[string]$ContentType
    ,[string]$stopWord
    ,[bool]$cache_prompt
    ,[bool]$stream
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # PowerShell
    $body = @{
        "prompt" = $prompt
    }

    if ($n_predict -ge 0) {
        $body["n_predict"] = $n_predict
    }

    if ($null -ne $stopWord -and $stopWord -ne "") {
        $body["stop"] = @($stopWord)
    }

    if ($cache_prompt -ge 0) {
        $body["cache_prompt"] = $cache_prompt
    }

    if ($stream -ge 0) {
        $body["stream"] = $stream
    }

    $jsonBody = $body | ConvertTo-Json

    Write-Verbose "Sending POST request to $Uri with jsonBody: $jsonBody"

    # stream対応するから実装。出力を確認する程度の意図
    Write-Host ""
    Write-Host ""
    #Write-Host "Copilot: " -NoNewline
    Write-Host "Copilot: "

    # $stream の値に関わらず、streamとして処理する
    $request = [System.Net.HttpWebRequest]::Create($Uri)
    $request.Method = "POST"
    $request.ContentType = $ContentType
    $request.Accept = "application/json"

    $requestStream = $request.GetRequestStream()
    $writer = New-Object System.IO.StreamWriter($requestStream)
    $writer.Write($jsonBody)
    $writer.Flush()
    $writer.Close()

    $requestResponse = $request.GetResponse()
    $requestResponseReader = New-Object System.IO.StreamReader($requestResponse.GetResponseStream())

    $contentStream = ""
    while (-not $requestResponseReader.EndOfStream) {
      $line = $requestResponseReader.ReadLine()
      $line = $line.TrimStart("data:")  # Remove "data:" from the beginning

      if ($line -ne "") {
        $response = $line | ConvertFrom-Json
        $contentStream += $response.content # 常に積み上げ

        # Check if content contains newline characters
        if ($response.content -match '\r\n|\n') {
          # Split content by newlines and process each line
          $contentLines = $response.content -split '\r\n|\n'
          for ($i = 0; $i -lt ($contentLines.Count - 1); $i++) {
              $contentLine = $contentLines[$i]
              Write-Host $contentLine
          }
        } else {
          # No newlines, process as before
          if ($null -ne $response.content) {
            Write-Host $response.content -NoNewline
          }
        }
      }
    }

    $requestResponseReader.Close()
    $requestResponse.Close()

    # stream対応するから実装。出力を確認する程度の意図
    Write-Host $response.stopping_word
    Write-Host ""
    Write-Host ""

    #末尾のresponseが呼び出しもとで求めるresponseのため調整
    $response.content = $contentStream

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  Write-Verbose "Received response: $response"

  return $response

}
