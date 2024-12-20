
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
    ,[string]$stopWord
  )

  try {

    # Call the common function
    WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters

    # 設定ファイル読み込み
    $config = Get-Content $configPath | Out-String | ConvertFrom-Json
    $n_predict = $config.n_predict
    $cache_prompt = $config.cache_prompt
    $stream = $config.stream
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
    $stopWord = RemoveSpecifiedStrings -configPath $configPath -inputString $stopWord

    if ($conversationHistory) {
        # $conversationHistoryの末尾に$assistant_eが付加されているかチェックし、付加されていなければ付加する
        if (-not $conversationHistory.EndsWith($assistant_e)) {
            # キャッシュを意識して改行を挟む。
            $conversationHistory += "`r`n" + $assistant_e
        }
        $prompt = $conversationHistory + $user_s + $userPrompt + $user_e + $assistant_s + $assistantPrompt
    } else {
        $prompt = $system_s + $systemPrompt + $system_e + $user_s + $userPrompt + $user_e + $assistant_s + $assistantPrompt
    }
    # キャッシュを意識して改行を挟む。
    # いったん改行の有無にかかわらず改行を除去したうえで、改行を挟む。
    $prompt = $prompt -replace "(\r?\n)$", "" # 末尾の改行を除去
    $prompt += "`r`n"

    # 推論実行
    $response = Inference -prompt $prompt -n_predict $n_predict -Uri $Uri -ContentType $ContentType -stopWord $stopWord -cache_prompt $cache_prompt -stream $stream

  }
  catch {
    Write-Error -Message "$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) ) "
  }

  return $response
}
