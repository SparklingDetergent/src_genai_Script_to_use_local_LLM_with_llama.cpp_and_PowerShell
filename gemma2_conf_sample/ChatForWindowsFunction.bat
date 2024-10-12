REM ƒTƒ“ƒvƒ‹


powershell -NoProfile -ExecutionPolicy Bypass  -Command "$VerbosePreference='Continue';$ErrorActionPreference='Stop';" ./ChatForWindows.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './output'

pause
pause
pause
