
# 推論の例

# main処理 param
param(
  [string]$dummy
  ,[string]$prompt
  ,[int]$n_predict
  ,[string]$Uri
  ,[string]$ContentType
  ,[string]$stopWord
  ,[bool]$cache_prompt
  ,[bool]$stream
)

. ./InferenceFunction.ps1

# main処理

# Check if the script is being run directly
if ($MyInvocation.InvocationName -eq '.') {
  Write-Verbose "The script is being dot-sourced, not run directly."
} else {
  Write-Verbose "The script is being run directly."
  # main処理
  try {

	# debug
    Inference -prompt "<|system|> You are a python programming specialist. <|end|><|user|> Create a program that displays 'Hello, World!'. <|end|><|assistant|>" -n_predict 16 -Uri "http://127.0.0.1:8085/completion" -ContentType "application/json" -stopWord "?" -cache_prompt $true -stream $true

    # Inference -prompt $prompt -n_predict $n_predict -Uri $Uri -ContentType $ContentType

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}


# ari
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Inference.ps1

# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./Inference.ps1

