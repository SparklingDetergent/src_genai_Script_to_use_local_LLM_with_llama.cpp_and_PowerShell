powershell -NoProfile -ExecutionPolicy Bypass  -Command "$VerbosePreference='Continue';$ErrorActionPreference='Stop';" ./ChatForWindows.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -defaultUserPromptPath './defaultUserPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -stopWordPath './stopWord.conf' -outputPath './multi_sample/やればできる/output' -afterUserPromptPath './multi_sample/やればできる/afterUserPrompt.conf' 
