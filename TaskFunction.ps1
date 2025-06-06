
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
    ,[string[]]$previousStoppingWordPath
    ,[string[]]$systemPromptPath
    ,[string[]]$userPromptPath
    ,[string[]]$assistantPromptPath
    ,[string[]]$stopWordPath
    ,[string]$outputPath
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 出力ファイルパスの処理
    $outputPath = ProcessOutputPath -outputPath $outputPath

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json
    $contentFileName = $config.contentFileName
    $stoppingWordFileName = $config.stoppingWordFileName
    $responseFileName = $config.responseFileName
    $promptFileName = $config.promptFileName


    # 前回のプロンプトの読み込み例
    foreach ($path in $previousPromptPath) {

      # テキストではなくバイトで連結する修正。Unicode Bom を考慮した連結。
      # $previousPrompt += $(Get-Content $path | Out-String )
      $additionalContent = [System.IO.File]::ReadAllBytes($path)
      $additionalString = [System.Text.Encoding]::Unicode.GetString($additionalContent)
      $additionalString = $additionalString.TrimStart([char]0xFEFF)
      $previousPrompt = $previousPrompt + $additionalString

      $previousPrompt = $previousPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # 前回の回答の読み込み例
    foreach ($path in $previousContentPath) {

      # テキストではなくバイトで連結する修正。Unicode Bom を考慮した連結。
      # $previousContent += $(Get-Content $path | Out-String )
      $additionalContent = [System.IO.File]::ReadAllBytes($path)
      $additionalString = [System.Text.Encoding]::Unicode.GetString($additionalContent)
      $additionalString = $additionalString.TrimStart([char]0xFEFF)
      $previousContent = $previousContent + $additionalString

      $previousContent = $previousContent -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # 前回のストッピングワードの読み込み例
    foreach ($path in $previousStoppingWordPath) {

      # テキストではなくバイトで連結する修正。Unicode Bom を考慮した連結。
      # $previousStoppingWord += $(Get-Content $path | Out-String )
      $additionalContent = [System.IO.File]::ReadAllBytes($path)
      $additionalString = [System.Text.Encoding]::Unicode.GetString($additionalContent)
      $additionalString = $additionalString.TrimStart([char]0xFEFF)
      $previousStoppingWord = $previousStoppingWord + $additionalString

      $previousStoppingWord = $previousStoppingWord -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # 会話履歴の作成
    $conversationHistory = $previousPrompt + $previousContent + $previousStoppingWord

    # システムプロンプトの読み込み例
    foreach ($path in $systemPromptPath) {
      $systemPrompt += $(Get-Content $path | Out-String )
      $systemPrompt = $systemPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # ユーザープロンプトの読み込み例
    foreach ($path in $userPromptPath) {
      $userPrompt += $(Get-Content $path | Out-String )
      $userPrompt = $userPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # アシスタントプロンプトの読み込み例
    foreach ($path in $assistantPromptPath) {
      $assistantPrompt += $(Get-Content $path | Out-String )
      $assistantPrompt = $assistantPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # ストップワードの読み込み例
    foreach ($path in $stopWordPath) {
      $stopWord += $(Get-Content $path | Out-String )
      $stopWord = $stopWord -replace "(\r?\n)$", "" # 末尾の改行を除去
    }

    # 会話実行
    $response = Conversation -conversationHistory $conversationHistory -systemPrompt $systemPrompt -userPrompt $userPrompt -assistantPrompt $assistantPrompt -stopWord $stopWord

    # 変数の型を取得します
    $type = $response.GetType()

    # 型の名前を表示します
    Write-Verbose $type.FullName

    # PSCustomObjectの各プロパティに対してループを行います
    foreach ($property in $response.PSObject.Properties) {
        # プロパティの名前と値を取得します
        $propertyName = $property.Name
        $propertyValue = $property.Value

        $filename = $outputPath + "$propertyName.txt"

        # プロパティの値をテキストファイルに書き込みます
        # $propertyValue | Out-File -FilePath $filename 
        # $propertyValue | Out-File -FilePath $filename -Encoding Unicode
        $propertyValue | Out-File -FilePath $filename -Encoding Unicode

        # ファイル名と指定ファイル名が一致する場合
        # Write-Verbose " propertyName = $propertyName.txt"
        # Write-Verbose " promptFileName = $promptFileName"
#        if ("$propertyName.txt" -eq "$promptFileName") {
#            $propertyValue | Out-File -FilePath "$filename.MD" -Encoding Unicode # MD ファイル出力対応
#        }

    }

    # アシスタントプロンプト、コンテンツ、ストッピングワードを結合し、生成結果をテキストファイルに書き込みます
    # $assistantPrompt = $assistantPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
    # 色々迷ったけど、assistantPromptについては改行処理しないほうがコーディングタスクなどで弊害がないので、自然にしておく。
    # ストッピングワードの結果ファイルも読み込み結合。

    $contentPath = $outputPath + $contentFileName
    $content = $(Get-Content $contentPath | Out-String )
#    $content | Out-File -FilePath "$contentPath.MD" -Encoding Unicode # MD ファイル出力対応
    $content = $content -replace "(\r?\n)$", "" # 末尾の改行を除去

    $stoppingWordPath = $outputPath + $stoppingWordFileName
    $stoppingWord = $(Get-Content $stoppingWordPath | Out-String )
    $stoppingWord = $stoppingWord -replace "(\r?\n)$", "" # 末尾の改行を除去

    $responseValue = "$assistantPrompt$content$stoppingWord"

    $responseValue = RemoveSpecifiedStrings -configPath $configPath -inputString $responseValue
    $responseFilePath = $outputPath + $responseFileName
    $responseValue | Out-File -FilePath $responseFilePath -Encoding Unicode
#    $responseValue | Out-File -FilePath "$responseFilePath.MD" -Encoding Unicode # MD ファイル出力対応


  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  return $response
}
