
# 出力先の処理の共通関数。

# main処理 param
param(
  [string]$dummy
  ,[string]$outputPath
)

. ./ProcessOutputPathFunction.ps1

# main処理

# Check if the script is being run directly
if ($MyInvocation.InvocationName -eq '.') {
  Write-Verbose "The script is being dot-sourced, not run directly."
} else {
  Write-Verbose "The script is being run directly."
  # main処理
  try {

	# debug
    # $outputPath = "./output"

    # 変数の型を取得します
    # $type = $outputPath.GetType()

    # 型の名前を表示します
    # Write-Verbose $type.FullName

    $outputPath = ProcessOutputPath -outputPath $outputPath

    # Write-Verbose "outputPath : $outputPath"

    # 変数の型を取得します
    # $type = $outputPath.GetType()

    # 型の名前を表示します
    # Write-Verbose $type.FullName

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}


# ari
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ProcessOutputPath.ps1 -outputPath  "./output"

#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ProcessOutputPath.ps1


# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./ProcessOutputPath.ps1

