
# 会話の例

# main処理 param
param(
  [string]$dummy
  ,[string]$configPath = "./configure.json"
  ,[string]$conversationHistory
  ,[string]$systemPrompt
  ,[string]$userPrompt
  ,[string]$assistantPrompt
  ,[string]$stopWord
)

. ./ConversationFunction.ps1
    
# main処理

# Check if the script is being run directly
if ($MyInvocation.InvocationName -eq '.') {
  Write-Verbose "The script is being dot-sourced, not run directly."
} else {
  Write-Verbose "The script is being run directly."
  # main処理
  try {

    # debug

    # システムプロンプトの読み込み例
    # $systemPromptPath = "./systemPrompt.conf"
    # $systemPrompt = $(Get-Content $systemPromptPath | Out-String )

    # ユーザープロンプトの読み込み例
    # $userPromptPath = "./userPrompt.conf"
    # $userPrompt = $(Get-Content $userPromptPath | Out-String )

    # アシスタントプロンプトの読み込み例
    # $assistantPromptPath = "./assistantPrompt.conf"
    # $assistantPrompt = $(Get-Content $assistantPromptPath | Out-String )

    # ストップワードの読み込み例
    # $stopWordPath = "./stopWord.conf"
    # $stopWord = $(Get-Content $stopWordPath | Out-String )

    # 会話実行
    Conversation -configPath $configPath -conversationHistory $conversationHistory -systemPrompt $systemPrompt -userPrompt $userPrompt -assistantPromptPath $assistantPromptPath -stopWordPath $stopWordPath 

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}



# ari
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Conversation.ps1

# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./Conversation.ps1
