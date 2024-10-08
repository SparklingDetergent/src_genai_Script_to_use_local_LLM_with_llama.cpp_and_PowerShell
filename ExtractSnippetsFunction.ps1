
# ソースコード抜き出しの例

# main処理 function

. ./WriteParametersFunction.ps1
. ./ProcessOutputPathFunction.ps1

function ExtractSnippets {
  param (
    [string]$dummy
    ,[string]$inputFile
    ,[string]$outputPath
    ,[string]$outputFilePrefix = "snippet"
    ,[string]$outputFileExtension = ".ps1"
    ,[string]$patternSnippet = "``````"
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 初期化
    $counter = 0
    $snippet = $null

    # 出力ファイルパスの処理
    $outputPath = ProcessOutputPath -outputPath $outputPath

    # 入力ファイルを読み込む
    $lines = Get-Content -Path $inputFile
    Write-Verbose "lines : $lines "

    foreach ($line in $lines) {

        # マッチするすべてのスニペットを取得
        $matches = [regex]::Matches($line, $patternSnippet)
        Write-Verbose "matches : $matches "

        if ($matches.Count -ne 0) {
            if ($snippet -ne $null) {
                # OutputFilePathN.ps1 ファイルにコードスニペットを書き込む
                $index = $counter + 1
                $snippet | Out-File -FilePath "$outputPath$outputFilePrefix$index$outputFileExtension"
                $counter++
                $snippet = $null
            } else {
                $snippet = ""
            }
        } elseif ($snippet -ne $null) {
            $snippet += $line + "`n"
        }
    }

    return $counter

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

}
