
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

    $jsonBody = $body | ConvertTo-Json

    Write-Verbose "Sending POST request to $Uri with jsonBody: $jsonBody"

    $response = Invoke-RestMethod -Method Post -Uri $Uri -ContentType $ContentType -Body $jsonBody

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  Write-Verbose "Received response: $response"

  return $response

}
