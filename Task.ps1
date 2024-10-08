
# 作業の例

# main処理 param
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

. ./TaskFunction.ps1

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

    # ユーザープロンプトの読み込み例
    # $userPromptPath = "./userPrompt.conf"

    # アシスタントプロンプトの読み込み例
    # $assistantPromptPath = "./assistantPrompt.conf"

    # ストップワードの読み込み例
    # $stopWordPath = "./stopWord.conf"

    # 出力先の読み込み例
    # $outputPath = "./output"
    
    Task -configPath $configPath -previousPromptPath $previousPromptPath -previousContentPath $previousContentPath -previousStoppingWordPath $previousStoppingWordPath -systemPromptPath $systemPromptPath -userPromptPath $userPromptPath  -assistantPromptPath $assistantPromptPath -stopWordPath $stopWordPath -outputPath $outputPath

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}



# ari
# debug
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Task.ps1

# やっとまともに引数設定できるようになった。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Task.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -userPromptPath './userPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

# 会話履歴の有無により分岐する処理とした。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Task.ps1 -configPath './configure.json' -previousPromptPath './prompt.txt' -previousContentPath './content.txt' -previousStoppingWordPath './stopping_word.txt' -systemPromptPath './systemPrompt.conf' -userPromptPath './userPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./Task.ps1
