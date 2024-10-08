
# チャットの例

# main処理 param
param(
  [string]$dummy
  ,[string]$configPath = "./configure.json"
  ,[string]$systemPrompt = " You are a helpful assistant. "
  ,[string]$outputPath = "./output"
)

. ./InteractiveFunction.ps1

# main処理

# Check if the script is being run directly
if ($MyInvocation.InvocationName -eq '.') {
  Write-Verbose "The script is being dot-sourced, not run directly."
} else {
  Write-Verbose "The script is being run directly."
  # main処理
  try {

    # debug

    Interactive -configPath $configPath -systemPrompt $systemPrompt -outputPath $outputPath

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}



#cd /content/drive/MyDrive/powershell
# ari
# debug
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Interactive.ps1

# やっとまともに引数設定できるようになった。
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Interactive.ps1 -configPath './configure.json' -systemPrompt ''

# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./Interactive.ps1
