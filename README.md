# src_genai_Script_to_use_local_LLM_with_llama.cpp_and_PowerShell
ローカルLLMをllama.cppとPowerShellで利用するスクリプト


# Chat.ps1

<br/><br/>
## on Windows powershell

```bash
powershell -NoProfile -ExecutionPolicy Bypass  -Command "$VerbosePreference='Continue';$ErrorActionPreference='Stop';" ./Chat.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -outputPath './output'
```

<br/><br/>
## on Windows pwsh

```bash
pwsh -NoProfile -ExecutionPolicy Bypass  -Command "$VerbosePreference='Continue';$ErrorActionPreference='Stop';" ./Chat.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -outputPath './output'
```

<br/><br/>
## on Linux pwsh

```bash
pwsh -NoProfile -ExecutionPolicy Bypass  -Command '$VerbosePreference="Continue";$ErrorActionPreference="Stop";' ./Chat.ps1 -configPath './configure.json' -systemPromptPath './systemPrompt.conf' -assistantPromptPath './assistantPrompt.conf' -outputPath './output'
```

