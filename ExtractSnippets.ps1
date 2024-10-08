
# ソースコード抜き出しの例

# main処理 param
param (
  [string]$dummy
  ,[string]$inputFile
  ,[string]$outputPath
  ,[string]$outputFilePrefix = "snippet"
  ,[string]$outputFileExtension = ".ps1"
  ,[string]$patternSnippet = "``````"
)

. ./ExtractSnippetsFunction.ps1

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
    # $inputFile = "./content.txt"

    # 出力先の読み込み例
    # $outputPath = "./output"

    # 出力ファイル名のプレフィックス
    # $outputFilePrefix = "snippet"

    # 出力ファイル名の拡張子
    # $outputFileExtension = ".ps1"

    # スニペットを抽出する正規表現パターン
    # $patternSnippet = "``````"


    # 関数のテストコード
    ExtractSnippets -inputFile $inputFile  -outputPath $outputPath -outputFilePrefix $outputFilePrefix  -outputFileExtension $outputFileExtension   -patternSnippet $patternSnippet 

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }
}



# ari
# debug
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExtractSnippets.ps1

# 引数あり実行


# ps1 形式
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExtractSnippets.ps1 -inputFile  "./content.txt" -outputPath "./output" -outputFilePrefix  "snippet"  -outputFileExtension ".ps1" -patternSnippet "\`\`\`"
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExtractSnippets.ps1 -inputFile  "./content.txt" -outputPath "./output"

# json 形式
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./ExtractSnippets.ps1 -inputFile  "./content.txt" -outputPath "./output" -outputFilePrefix  "snippet"  -outputFileExtension ".json" -patternSnippet "\`\`\`"


# nashi
#powershell -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="SilentlyContinue";$ErrorActionPreference="Stop";' ./ExtractSnippets.ps1
