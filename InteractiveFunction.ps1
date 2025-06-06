
# チャットの例

# main処理 function

. ./WriteParametersFunction.ps1
. ./ConversationFunction.ps1
    
function Interactive {
  param(
    [string]$dummy
    ,[string]$configPath = "./configure.json"
    ,[string]$systemPrompt = " You are a helpful assistant. "
    ,[string]$outputPath = "./output"
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    while(1) {

      $inputString = Read-Host -Prompt " ?"

      $userPrompt = $inputString

      # 会話実行
      $response = Conversation -systemPrompt $systemPrompt -userPrompt $userPrompt

      # プロパティ名 'content' の値を取得します
      $propertyValue = $response.PSObject.Properties['content'].Value

      # 値を標準出力します
      #Write-Host "`nCopilot: $propertyValue`n" -ForegroundColor Green
      Write-Host "`nCopilot: `n$propertyValue`n" -ForegroundColor Green

    }

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  return $response
}
