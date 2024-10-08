
# コマンド実行の例

# main処理 function

. ./WriteParametersFunction.ps1
. ./ProcessOutputPathFunction.ps1

function ExecuteCommands {
  param (
    [string]$dummy
    ,[string]$inputFile
    ,[string]$outputPath
    ,[string]$outputFilePrefix = "command"
    ,[string]$outputFileExtension = ".txt"
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 出力ファイルパスの処理
    $outputPath = ProcessOutputPath -outputPath $outputPath

    # ファイルからコマンドを読み込む
    $commands = Get-Content $inputFile
    Write-Verbose "commands : $commands"

    $counter = 0
    foreach ($command in $commands) {
        # コマンドの実行

        $index = $counter + 1

        # コマンドを空白で分割
        $splitCommand = $command -split ' ', 2

        # FilePathとArgumentListの引数を設定
        $filePath = $splitCommand[0]
        Write-Verbose "filePath : $filePath"

        $argumentList = $splitCommand[1]
        Write-Verbose "argumentList : $argumentList"
#        $argumentList = $argumentList -split ' '
#        Write-Verbose "argumentList : $argumentList"

        $process = Start-Process -FilePath $filePath -ArgumentList $argumentList -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$outputPath\$outputFilePrefix$index.out$outputFileExtension" -RedirectStandardError "$outputPath\$outputFilePrefix$index.err$outputFileExtension"

        # リターンコードの保存
        $process.ExitCode | Out-File "$outputPath\$outputFilePrefix$index.returncode$outputFileExtension"

        $counter++
    }

    return $counter

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

}

