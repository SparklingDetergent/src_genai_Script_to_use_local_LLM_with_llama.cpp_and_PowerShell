REM ƒTƒ“ƒvƒ‹

cd /d C:\work\powershell\Phi-3.1\

powershell -NoProfile -ExecutionPolicy Bypass  -Command "$VerbosePreference='Continue';$ErrorActionPreference='Stop';" ./ChatForWindows.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -outputPath './output'

pause
pause
pause
