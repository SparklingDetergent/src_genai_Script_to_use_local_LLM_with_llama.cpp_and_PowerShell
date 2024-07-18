param (
    [string]$filePath = "C:\Minecraft\Worlds\Among Us\server.properties",
    [string]$settingItem = "server-name=",
    [string]$value = "Among Us"
)

# �t�@�C���̓��e��ǂݍ���
$content = Get-Content -Path $filePath

# �ݒ荀�ڂ̍s��������
$lineIndex = $content | Select-String -Pattern $settingItem | Select-Object -ExpandProperty LineNumber -First 1

if ($null -ne $lineIndex) {
    # �ݒ荀�ڂ����������ꍇ�A�l���X�V����
    $content[$lineIndex - 1] = "$settingItem$value"
} else {
    # �ݒ荀�ڂ�������Ȃ������ꍇ�A�V���ɒǉ�����
    $content += "$settingItem$value"
}

# �X�V�������e���t�@�C���ɏ�������
# $content | Out-File -FilePath $filePath
$content | Out-File -FilePath $filePath -Encoding utf8NoBOM


# $content | %{ $_+"`n" } | ForEach-Object{ [Text.Encoding]::UTF8.GetBytes($_) } | Set-Content -Encoding Byte -Path $filePath

# BOM�Ȃ���UTF8Encoding�I�u�W�F�N�g���쐬
# $UTF8woBOM = New-Object "System.Text.UTF8Encoding" -ArgumentList @($false)

# .NET Framework��IO�������g�p���ăt�@�C���ɏ�������
# [System.IO.File]::WriteAllLines($filePath, $content, $UTF8woBOM)

# Write-Host $filePath

# Write-Host $content

#pwsh -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' C:\Minecraft\Worlds\UpdateServerProperties.ps1 -filePath "C:\Minecraft\Worlds\My_World\server.properties" -settingItem "server-name=" -value "My_World"


