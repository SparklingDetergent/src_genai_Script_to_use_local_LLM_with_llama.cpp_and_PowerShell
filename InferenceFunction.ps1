
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
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # PowerShell
    $body = @{
        "prompt" = $prompt
        "n_predict" = $n_predict
    } | ConvertTo-Json
    Write-Verbose "Sending POST request to $Uri with body: $body"

    $response = Invoke-RestMethod -Method Post -Uri $Uri -ContentType $ContentType -Body $body

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  Write-Verbose "Received response: $response"

  return $response

}
