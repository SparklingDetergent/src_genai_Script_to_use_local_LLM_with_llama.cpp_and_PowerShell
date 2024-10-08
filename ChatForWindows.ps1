
# 作業の例

# main処理 param
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

. ./ChatForWindowsFunction.ps1

# main処理

# Check if the script is being run directly
if ($MyInvocation.InvocationName -eq '.') {
  Write-Verbose "The script is being dot-sourced, not run directly."
} else {
  Write-Verbose "The script is being run directly."
  # main処理
  try {

    # debug
    # $prompt = "<|system|> You are a python programming specialist. <|end|><|user|> Create a program that displays 'Hello, World!'. <|end|><|assistant|>"

    # システムプロンプトの読み込み例
    # $systemPromptPath = "./systemPrompt.conf"

    # アシスタントプロンプトの読み込み例
    # $assistantPromptPath = "./assistantPrompt.conf"

    # ストップワードの読み込み例
    # $stopWordPath = "./stopWord.conf"

    # 出力先の読み込み例
    # $outputPath = "./output"
    
    ChatForWindows -configPath $configPath -previousPromptPath $previousPromptPath -previousContentPath $previousContentPath -previousStoppingWordPath $previousStoppingWordPath -systemPromptPath $systemPromptPath -beforeUserPromptPath $beforeUserPromptPath -afterUserPromptPath $afterUserPromptPath -defaultUserPromptPath $defaultUserPromptPath -assistantPromptPath $assistantPromptPath -stopWordPath $stopWordPath -outputPath $outputPath

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}



#cd /content/drive/MyDrive/powershell


# ari
# debug
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ChatForWindows.ps1

# やっとまともに引数設定できるようになった。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ChatForWindows.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

# 会話履歴の有無により分岐する処理とした。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ChatForWindows.ps1 -configPath './configure.json' -previousPromptPath './prompt.txt' -previousContentPath './content.txt' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

# ユーザープロンプトパスを入力プロンプトの前後に入れるように対応してみた。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ChatForWindows.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -beforeUserPromptPath './beforeUserPrompt.conf' -afterUserPromptPath './afterUserPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

# デフォルトプロンプトパスを初回の入力プロンプトとして設定できるようにした。。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ChatForWindows.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -beforeUserPromptPath './beforeUserPrompt.conf' -afterUserPromptPath './afterUserPrompt.conf' -defaultUserPromptPath './defaultUserPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./ChatForWindows.ps1
