param (
    [string]$filePath = "C:\Minecraft\Worlds\Among Us\server.properties",
    [string]$settingItem = "server-name=",
    [string]$value = "Among Us"
)

# ファイルの内容を読み込む
$content = Get-Content -Path $filePath

# 設定項目の行を見つける
$lineIndex = $content | Select-String -Pattern $settingItem | Select-Object -ExpandProperty LineNumber -First 1

if ($null -ne $lineIndex) {
    # 設定項目が見つかった場合、値を更新する
    $content[$lineIndex - 1] = "$settingItem$value"
} else {
    # 設定項目が見つからなかった場合、新たに追加する
    $content += "$settingItem$value"
}

# 更新した内容をファイルに書き込む
# $content | Out-File -FilePath $filePath
$content | Out-File -FilePath $filePath -Encoding utf8NoBOM


# $content | %{ $_+"`n" } | ForEach-Object{ [Text.Encoding]::UTF8.GetBytes($_) } | Set-Content -Encoding Byte -Path $filePath

# BOMなしのUTF8Encodingオブジェクトを作成
# $UTF8woBOM = New-Object "System.Text.UTF8Encoding" -ArgumentList @($false)

# .NET FrameworkのIO処理を使用してファイルに書き込む
# [System.IO.File]::WriteAllLines($filePath, $content, $UTF8woBOM)

# Write-Host $filePath

# Write-Host $content

#pwsh -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' C:\Minecraft\Worlds\UpdateServerProperties.ps1 -filePath "C:\Minecraft\Worlds\My_World\server.properties" -settingItem "server-name=" -value "My_World"


