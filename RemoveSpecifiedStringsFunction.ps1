# Param表示の共通関数。

# main処理 function

function RemoveSpecifiedStrings {
    param (
        [string]$dummy
        ,[string]$configPath = "./configure.json"
        ,[string]$inputString
    )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json

    # プロンプトテンプレートファイルの読み込み
    $system_s = $config.system_s
    $system_e = $config.system_e
    $user_s = $config.user_s
    $user_e = $config.user_e
    $assistant_s = $config.assistant_s
    $assistant_e = $config.assistant_e

    # 特定の文字列を除外
    $inputString = $inputString.Replace($system_s, "").Replace($system_e, "").Replace($user_s, "").Replace($user_e, "").Replace($assistant_s, "").Replace($assistant_e, "")

    return $inputString

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

}
