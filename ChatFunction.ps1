
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
    ,[string[]]$previousStoppingWordPath
    ,[string[]]$systemPromptPath
    ,[string[]]$beforeUserPromptPath
    ,[string[]]$afterUserPromptPath
    ,[string[]]$defaultuserPromptPath
    ,[string[]]$assistantPromptPath
    ,[string[]]$stopWordPath
    ,[string]$outputPath
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json
    $before_and_after_user_prompts_only_for_the_first_time = $config.before_and_after_user_prompts_only_for_the_first_time
    $userPromptFileName = $config.userPromptFileName
    $promptFileName = $config.promptFileName
    $contentFileName = $config.contentFileName
    $stoppingWordFileName = $config.stoppingWordFileName

    $before_and_after_user_prompts = $true

    while(1) {

      # 出力ファイルパスの処理（ワーク）
      $workOutputPath = ProcessOutputPath -outputPath $outputPath

      # ユーザープロンプトの読み込み例
      $userPrompt = ""
      foreach ($path in $defaultuserPromptPath) {
        $userPrompt += $(Get-Content $path | Out-String )
        $userPrompt = $userPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
      }

      if ( $userPrompt -ne "" ) {
        # ユーザープロンプトを入力プロンプトへ設定
        $inputPrompt = $userPrompt

        # defaultuserPromptPath クリア（初回起動時のみ有効とし、以降は無効とするため）
        $defaultuserPromptPath = @()

      } else {
        # 入力プロンプトの読み込み
        $inputPrompt = Read-Host -Prompt " ?"

      }

      # 入力プロンプトパスの設定
      $inputPromptPath = $workOutputPath + $userPromptFileName

      # 入力プロンプトの書き込み
      $inputPrompt | Out-File -FilePath $inputPromptPath -Encoding Unicode

      # ユーザープロンプトパスの作成
      if ( $before_and_after_user_prompts ) {
#        $userPromptPath = @() + $beforeUserPromptPath + $inputPromptPath + $afterUserPromptPath

        $userPromptPath = @()
        if ($beforeUserPromptPath) {
            $userPromptPath += $beforeUserPromptPath
        }

        $userPromptPath += $inputPromptPath

        if ($afterUserPromptPath) {
            $userPromptPath += $afterUserPromptPath
        }

        if ( $before_and_after_user_prompts_only_for_the_first_time ) {
          $before_and_after_user_prompts = $false
        }

      } else {
          $userPromptPath = @() + $inputPromptPath
      }

      # タスク実行
      Task -previousPromptPath $previousPromptPath -previousContentPath $previousContentPath -previousStoppingWordPath $previousStoppingWordPath -systemPromptPath $systemPromptPath -userPromptPath $userPromptPath  -assistantPromptPath $assistantPromptPath -stopWordPath $stopWordPath -outputPath $workOutputPath

      # 前回のプロンプトパスの設定
      $previousPromptPath = $workOutputPath + $promptFileName

      # 前回の回答パスの設定
      $previousContentPath = $workOutputPath + $contentFileName

      # 前回の回答の読み込み
      $previousContent = Get-Content $previousContentPath | Out-String
      $previousContent = $previousContent -replace "(\r?\n)$", "" # 末尾の改行を除去

      # 値を標準出力します
#      Write-Host "`nCopilot: `n$previousContent`n" -ForegroundColor Green

      # 前回のストッピングワードパスの設定
      $previousStoppingWordPath = $workOutputPath + $stoppingWordFileName

      # 前回のストッピングワードの読み込み
      $previousStoppingWord = Get-Content $previousStoppingWordPath | Out-String
      $previousStoppingWord = $previousStoppingWord -replace "(\r?\n)$", "" # 末尾の改行を除去

      # 値を標準出力します
#      Write-Host "`n$previousStoppingWord`n" -ForegroundColor Green


    }

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  return $response
}
