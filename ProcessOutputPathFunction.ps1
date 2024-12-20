
# 出力先の処理の共通関数。

# main処理 function

. ./WriteParametersFunction.ps1

function ProcessOutputPath {
    param(
      [string]$dummy
      ,[string]$outputPath
      ,[string]$timestamp = ""
    )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 末尾に / がなければ追加
    if ($outputPath[-1] -ne "/") {
        $outputPath += "/"
    }

    # 末尾が "output/" であるかどうかを確認
    if ($outputPath -match "output/$") {
        # 現在の日付と時刻を取得
#        $currentDateTime = Get-Date -Format "yyyyMMddHHmmss"
#        $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        if ( $timestamp -eq "" ) {
            $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        } else {
            $currentDateTime = $timestamp
        }
        # outputPath の末尾に年月日時分秒を追加
        $outputPath += $currentDateTime + "/"
    }

    # 出力先のディレクトリが存在しない場合は作成
    if (!(Test-Path -Path $outputPath )) {
        $outputPathObject = New-Item -ItemType directory -Path $outputPath
        Write-Verbose "outputPathObject : $outputPathObject"

    }

    Write-Verbose "outputPath : $outputPath"

    # $outputPath | Format-List -Property * 
    # Write-Verbose $outputPath | Format-List -Property * 

    # 処理結果のoutputPathを返す
    return $outputPath

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

}
