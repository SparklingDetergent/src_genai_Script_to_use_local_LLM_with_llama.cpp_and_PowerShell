
# ソースコード抜き出しの例

# main処理 param
 param (
  [string]$dummy
  ,[string]$inputFile
  ,[string]$outputPath
  ,[string]$outputFilePrefix = "command"
  ,[string]$outputFileExtension = ".txt"
 )


. ./ExecuteCommandsFunction.ps1

# main処理

# Check if the script is being run directly
if ($MyInvocation.InvocationName -eq '.') {
  Write-Verbose "The script is being dot-sourced, not run directly."
} else {
  Write-Verbose "The script is being run directly."
  # main処理
  try {

    # debug

    # 入力ファイルの読み込み例
    # $inputFile = "./command.txt"

    # 出力先の読み込み例
    # $outputPath = "./output"

    # 出力ファイル名のプレフィックス
    # $outputFilePrefix = "command"

    # 出力ファイル名の拡張子
    # $outputFileExtension = ".txt"

    # 関数のテストコード
    ExecuteCommands -inputFile $inputFile  -outputPath $outputPath -outputFilePrefix $outputFilePrefix  -outputFileExtension $outputFileExtension

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}



# ari
# debug
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExecuteCommands.ps1

# 引数あり実行
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExecuteCommands.ps1 -inputFile  "./command.txt" -outputPath "./output" -outputFilePrefix  "command"  -outputFileExtension ".txt"

#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExecuteCommands.ps1 -inputFile  "./command.txt" -outputPath "./output"

# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./ExecuteCommands.ps1
