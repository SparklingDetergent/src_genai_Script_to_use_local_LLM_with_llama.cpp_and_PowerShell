
# 作業の例

# main処理 function

. ./WriteParametersFunction.ps1
. ./ProcessOutputPathFunction.ps1
. ./ConversationFunction.ps1
    
function Task {
  param(
    [string]$dummy
    ,[string]$configPath = "./configure.json"
    ,[string[]]$previousPromptPath
    ,[string[]]$previousContentPath
    ,[string[]]$systemPromptPath
    ,[string[]]$userPromptPath
    ,[string[]]$assistantPromptPath
    ,[string]$outputPath
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 出力ファイルパスの処理
    $outputPath = ProcessOutputPath -outputPath $outputPath

    # 前回のプロンプトの読み込み例
    foreach ($path in $previousPromptPath) {
      $previousPrompt += $(Get-Content $path | Out-String )
    }

    # 前回の回答の読み込み例
    foreach ($path in $previousContentPath) {
      $previousContent += $(Get-Content $path | Out-String )
    }

    # 会話履歴の作成
    $conversationHistory = $previousPrompt + $previousContent

    # システムプロンプトの読み込み例
    foreach ($path in $systemPromptPath) {
      $systemPrompt += $(Get-Content $path | Out-String )
    }

    # ユーザープロンプトの読み込み例
    foreach ($path in $userPromptPath) {
      $userPrompt += $(Get-Content $path | Out-String )
    }

    # アシスタントプロンプトの読み込み例
    foreach ($path in $assistantPromptPath) {
      $assistantPrompt += $(Get-Content $path | Out-String )
    }

    # 会話実行
    $response = Conversation -conversationHistory $conversationHistory -systemPrompt $systemPrompt -userPrompt $userPrompt -assistantPrompt $assistantPrompt

    # 変数の型を取得します
    $type = $response.GetType()

    # 型の名前を表示します
    Write-Verbose $type.FullName

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json
    $contentPropertyName = $config.contentPropertyName
    $responseFileName = $config.responseFileName

    # PSCustomObjectの各プロパティに対してループを行います
    foreach ($property in $response.PSObject.Properties) {
        # プロパティの名前と値を取得します
        $propertyName = $property.Name
        $propertyValue = $property.Value

        $filename = $outputPath + "$propertyName.txt"

        # プロパティの値をテキストファイルに書き込みます
        # $propertyValue | Out-File -FilePath $filename 
        # $propertyValue | Out-File -FilePath $filename -Encoding Unicode
        # プロパティの値をテキストファイルに書き込みます
        if ($contentPropertyName -eq $propertyName) {
            # $assistantPrompt = $assistantPrompt.TrimEnd("`n","`r") # 末尾の改行を除去
            # 色々迷ったけど、改行処理しないほうがコーディングタスクなどで弊害がないので、自然にしておく。
            $responseValue = "$assistantPrompt$propertyValue"
            $responseValue = RemoveSpecifiedStrings -configPath $configPath -inputString $responseValue
            $responseFilePath = $outputPath + $responseFileName
            $responseValue | Out-File -FilePath $responseFilePath -Encoding Unicode
        }
        $propertyValue | Out-File -FilePath $filename -Encoding Unicode

    }

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  Write-Verbose "Received response: $response"
  return $response
}
