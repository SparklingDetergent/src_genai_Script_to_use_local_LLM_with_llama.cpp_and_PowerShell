
# 作業の例

# main処理 function

. ./WriteParametersFunction.ps1
. ./ProcessOutputPathFunction.ps1
. ./TaskFunction.ps1
    
function Chat {
  param(
    [string]$dummy
    ,[string]$configPath = "./configure.json"
    ,[string[]]$previousPromptPath
    ,[string[]]$previousContentPath
    ,[string[]]$systemPromptPath
    ,[string[]]$assistantPromptPath
    ,[string]$outputPath
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json
    $userPromptFileName = $config.userPromptFileName
    $previousPromptFileName = $config.previousPromptFileName
    $previousContentFileName = $config.previousContentFileName

    while(1) {

      # ユーザープロンプトの読み込み
      $userPrompt = Read-Host -Prompt " ?"

      # 出力ファイルパスの処理（ワーク）
      $workOutputPath = ProcessOutputPath -outputPath $outputPath

      # ユーザープロンプトパスの設定
      $userPromptPath = $workOutputPath + $userPromptFileName

      # ユーザープロンプトの書き込み
      $userPrompt | Out-File -FilePath $userPromptPath -Encoding Unicode

      # タスク実行
      Task -previousPromptPath $previousPromptPath -previousContentPath $previousContentPath -systemPromptPath $systemPromptPath -userPromptPath $userPromptPath  -assistantPromptPath $assistantPromptPath -outputPath $workOutputPath

      # 前回のプロンプトパスの設定
      $previousPromptPath = $workOutputPath + $previousPromptFileName

      # 前回の回答パスの設定
      $previousContentPath = $workOutputPath + $previousContentFileName

      # 前回の回答の読み込み
      $previousContent = Get-Content $previousContentPath | Out-String

      # 値を標準出力します
      Write-Host "`nCopilot: $previousContent`n" -ForegroundColor Green

    }

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  Write-Verbose "Received response: $response"
  return $response
}
