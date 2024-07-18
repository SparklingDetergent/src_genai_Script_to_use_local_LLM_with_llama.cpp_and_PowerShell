
# 会話の例

# main処理 function

. ./WriteParametersFunction.ps1
. ./InferenceFunction.ps1
. ./RemoveSpecifiedStringsFunction.ps1
    
function Conversation {
  param(
    [string]$dummy
    ,[string]$configPath = "./configure.json"
    ,[string]$conversationHistory
    ,[string]$systemPrompt
    ,[string]$userPrompt
    ,[string]$assistantPrompt
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json
    $n_predict = $config.n_predict
    $Uri = $config.Uri
    $ContentType = $config.ContentType

    # プロンプトテンプレートファイルの読み込み
    $system_s = $config.system_s
    $system_e = $config.system_e
    $user_s = $config.user_s
    $user_e = $config.user_e
    $assistant_s = $config.assistant_s
    $assistant_e = $config.assistant_e

    # 特定の文字列を除外
    $systemPrompt = RemoveSpecifiedStrings -configPath $configPath -inputString $systemPrompt
    $userPrompt = RemoveSpecifiedStrings -configPath $configPath -inputString $userPrompt
    $assistantPrompt = RemoveSpecifiedStrings -configPath $configPath -inputString $assistantPrompt

    if ($conversationHistory) {
        $prompt = $conversationHistory + $user_s + $userPrompt + $user_e + $assistant_s + $assistantPrompt
    } else {
        $prompt = $system_s + $systemPrompt + $system_e + $user_s + $userPrompt + $user_e + $assistant_s + $assistantPrompt
    }

    # 推論実行
    $response = Inference -prompt $prompt -n_predict $n_predict -Uri $Uri -ContentType $ContentType

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  Write-Verbose "Received response: $response"
  return $response
}
