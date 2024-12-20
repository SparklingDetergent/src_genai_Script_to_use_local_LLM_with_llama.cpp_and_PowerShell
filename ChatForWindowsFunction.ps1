Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. ./WriteParametersFunction.ps1
. ./ProcessOutputPathFunction.ps1
. ./TaskFunction.ps1

function ChatForWindows {
    param(
        [string]$dummy
        ,[string]$configPath = "./configure.json"
        ,[string[]]$previousPromptPath
        ,[string[]]$previousContentPath
        ,[string[]]$previousStoppingWordPath
        ,[string[]]$systemPromptPath
        ,[string[]]$beforeUserPromptPath
        ,[string[]]$afterUserPromptPath
        ,[string[]]$defaultuserPromptPath
        ,[string[]]$assistantPromptPath
        ,[string[]]$stopWordPath
        ,[string]$outputPath
    )

    try {
        WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters
        $config = Get-Content $configPath | Out-String | ConvertFrom-Json
        $chatName = $config.chatName
        $minimizeAndWait = $config.minimizeAndWait
        $before_and_after_user_prompts_only_for_the_first_time = $config.before_and_after_user_prompts_only_for_the_first_time
        $userPromptFileName = $config.userPromptFileName
        $promptFileName = $config.promptFileName
        $contentFileName = $config.contentFileName
        $stoppingWordFileName = $config.stoppingWordFileName


        # Initialize script-scoped variables
        $script:previousPromptPath = $previousPromptPath
        $script:previousContentPath = $previousContentPath
        $script:previousStoppingWordPath = $previousStoppingWordPath
        $script:defaultuserPromptPath = $defaultuserPromptPath
        $script:before_and_after_user_prompts = $true

        $form = New-Object System.Windows.Forms.Form

#        $form.Text = "Chat for Windows"
        $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $form.Text = "$chatName ($currentDateTime~)"

        $form.Size = New-Object System.Drawing.Size(600,500)
        $form.MinimumSize = New-Object System.Drawing.Size(400,300)

        $chatBox = New-Object System.Windows.Forms.RichTextBox
        $chatBox.Multiline = $true
        $chatBox.ScrollBars = "Vertical"
        $chatBox.ReadOnly = $true
        $form.Controls.Add($chatBox)

        $inputBox = New-Object System.Windows.Forms.RichTextBox
        $inputBox.Multiline = $true
        $inputBox.ScrollBars = "Vertical"
        $form.Controls.Add($inputBox)

        $sendButton = New-Object System.Windows.Forms.Button
        $sendButton.Text = "Send"
        $form.Controls.Add($sendButton)

        $resetButton = New-Object System.Windows.Forms.Button
        $resetButton.Text = "Reset"
        $form.Controls.Add($resetButton)

        $ctrlEnterLabel = New-Object System.Windows.Forms.Label
        $ctrlEnterLabel.Text = "Press Ctrl + Enter to send"
        $ctrlEnterLabel.AutoSize = $true
        $form.Controls.Add($ctrlEnterLabel)

        $ctrlResetEnterLabel = New-Object System.Windows.Forms.Label
        $ctrlResetEnterLabel.Text = "Press Ctrl + Shift + Enter to reset and send"
        $ctrlResetEnterLabel.AutoSize = $true
        $form.Controls.Add($ctrlResetEnterLabel)

        $ctrlResetLabel = New-Object System.Windows.Forms.Label
        $ctrlResetLabel.Text = "Press Shift + Enter to reset"
        $ctrlResetLabel.AutoSize = $true
        $form.Controls.Add($ctrlResetLabel)

        # Function to adjust control sizes and positions
        function AdjustControlSizes {
            $clientSize = $form.ClientSize
            $padding = 10
            $buttonWidth = 90
            $buttonHeight = 30

            $totalHeight = $clientSize.Height - (3 * $padding)
            $chatBoxHeight = [Math]::Floor($totalHeight * 0.6)
            $inputBoxHeight = $totalHeight - $chatBoxHeight

            $chatBox.Location = New-Object System.Drawing.Point($padding, $padding)
            $chatBox.Size = New-Object System.Drawing.Size(($clientSize.Width - 2 * $padding), $chatBoxHeight)

            $inputBox.Location = New-Object System.Drawing.Point($padding, ($chatBoxHeight + 2 * $padding))
            $inputBox.Size = New-Object System.Drawing.Size(($clientSize.Width - 3 * $padding - $buttonWidth), $inputBoxHeight)

            $sendButton.Location = New-Object System.Drawing.Point(($clientSize.Width - $buttonWidth - $padding), ($chatBoxHeight + 2 * $padding))
            $sendButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)

            $ctrlEnterLabel.Location = New-Object System.Drawing.Point(($clientSize.Width - $buttonWidth - $padding), ($chatBoxHeight + 2 * $padding + $buttonHeight + 5))
            $ctrlEnterLabel.MaximumSize = New-Object System.Drawing.Size($buttonWidth, 0)
            $ctrlEnterLabel.AutoSize = $true

            $ctrlResetEnterLabel.Location = New-Object System.Drawing.Point(($clientSize.Width - $buttonWidth - $padding), ($chatBoxHeight + 2 * $padding + $buttonHeight + 5 + $buttonHeight + 5 + $buttonHeight + 5))
            $ctrlResetEnterLabel.MaximumSize = New-Object System.Drawing.Size($buttonWidth, 0)
            $ctrlResetEnterLabel.AutoSize = $true

            $ctrlResetLabel.Location = New-Object System.Drawing.Point(($clientSize.Width - $buttonWidth - $padding), ($clientSize.Height - $buttonHeight - $padding - $buttonHeight - $padding))
            $ctrlResetLabel.MaximumSize = New-Object System.Drawing.Size($buttonWidth, 0)
            $ctrlResetLabel.AutoSize = $true

            $resetButton.Location = New-Object System.Drawing.Point(($clientSize.Width - $buttonWidth - $padding), ($clientSize.Height - $buttonHeight - $padding))
            $resetButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)

        }

        # Initial adjustment
        AdjustControlSizes

        # Add Resize event handler
        $form.Add_Resize({ AdjustControlSizes })

        # グローバル変数としてファイルパス等を保持
        $global:chatBoxTimeStamp = ""
        $global:chatBoxFileName = ""
        $global:chatBoxFilePath = ""

        # 新しいファイルを作成する関数
        function InitializeChatBoxFile {
            param($outputPath)
#            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
#            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
            $global:chatBoxTimeStamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
            $global:chatBoxFileName = "ChatBox_$global:chatBoxTimeStamp.txt"
            $global:chatBoxFilePath = "$outputPath\$global:chatBoxFileName"
            "" | Out-File -FilePath $global:chatBoxFilePath -Encoding Unicode
        }

        # chatBox内容を保存する関数
        function SaveChatBoxContent {
            param($chatBoxContent, $workOutputPath)
#            $chatBoxContent | Out-File -FilePath $global:chatBoxFilePath -Encoding Unicode -Append

            # chatBoxの内容を保存
            $chatBoxContent | Out-File -FilePath $global:chatBoxFilePath -Encoding Unicode
            # 同一の内容でその時の会話履歴として保存（これが紐づけの情報になる）
            $chatBoxContent | Out-File -FilePath "$workOutputPath$global:chatBoxFileName" -Encoding Unicode

        }

#        # 初回起動時のファイル初期化
#        InitializeChatBoxFile -outputPath $outputPath

        $sendMessage = {

#            $workOutputPath = ProcessOutputPath -outputPath $outputPath
            if ( $global:chatBoxFilePath -eq "" ) {
                # 初回起動時のファイル初期化
                InitializeChatBoxFile -outputPath $outputPath
                $workOutputPath = ProcessOutputPath -outputPath $outputPath -timestamp $global:chatBoxTimeStamp
            } else {
                $workOutputPath = ProcessOutputPath -outputPath $outputPath
            }

            # Minimize the window
            if ( $minimizeAndWait ) {
                $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
            }

#            # Move focus to the previous window
#            [System.Windows.Forms.SendKeys]::SendWait("%{TAB}")

            # ユーザープロンプトの読み込み例
            $userPrompt = ""
            foreach ($path in $script:defaultuserPromptPath) {
              $userPrompt += $(Get-Content $path | Out-String )
              $userPrompt = $userPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
            }

            if ( $userPrompt -ne "" ) {
              # ユーザープロンプトを入力プロンプトへ設定
              $inputPrompt = $userPrompt

              # script:defaultuserPromptPath クリア（初回起動時のみ有効とし、以降は無効とするため）
              $script:defaultuserPromptPath = @()

            } else {
              # 入力プロンプトの読み込み
              $inputPrompt = $inputBox.Text
              if ([string]::IsNullOrWhiteSpace($inputPrompt)) { return }

            }
#            [System.Windows.Forms.MessageBox]::Show($inputPrompt, "Variable Value")

            # 入力プロンプトパスの設定
            $inputPromptPath = $workOutputPath + $userPromptFileName

            # 入力プロンプトの書き込み
            $inputPrompt | Out-File -FilePath $inputPromptPath -Encoding Unicode

            # ユーザープロンプトパスの作成
            if ( $script:before_and_after_user_prompts ) {
#              $userPromptPath = @() + $beforeUserPromptPath + $inputPromptPath + $afterUserPromptPath

              $userPromptPath = @()
              if ($beforeUserPromptPath) {
                $userPromptPath += $beforeUserPromptPath
              }

              $userPromptPath += $inputPromptPath

              if ($afterUserPromptPath) {
                $userPromptPath += $afterUserPromptPath
              }

              if ( $before_and_after_user_prompts_only_for_the_first_time ) {
                $script:before_and_after_user_prompts = $false
              }

            } else {
                $userPromptPath = @() + $inputPromptPath
            }

            Task -previousPromptPath $script:previousPromptPath -previousContentPath $script:previousContentPath -previousStoppingWordPath $script:previousStoppingWordPath -systemPromptPath $systemPromptPath -userPromptPath $userPromptPath -assistantPromptPath $assistantPromptPath -stopWordPath $stopWordPath -outputPath $workOutputPath

            # アシスタントプロンプトの読み込み例
            foreach ($path in $assistantPromptPath) {
              $assistantPrompt += $(Get-Content $path | Out-String )
              $assistantPrompt = $assistantPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
            }
            $previousContent = $assistantPrompt

            $script:previousPromptPath = $workOutputPath + $promptFileName

            $script:previousContentPath = $workOutputPath + $contentFileName
            $previousContent += Get-Content $script:previousContentPath | Out-String
            $previousContent = $previousContent -replace "(\r?\n)$", "" # 末尾の改行を除去

            $script:previousStoppingWordPath = $workOutputPath + $stoppingWordFileName
            $previousContent += Get-Content $script:previousStoppingWordPath | Out-String
            $previousContent = $previousContent -replace "(\r?\n)$", "" # 末尾の改行を除去

            # ユーザープロンプトの読み込み例
            $userPrompt = ""
            foreach ($path in $userPromptPath) {
              $userPrompt += $(Get-Content $path | Out-String )
              $userPrompt = $userPrompt -replace "(\r?\n)$", "" # 末尾の改行を除去
            }
            $chatBox.AppendText("`r`n`r`n🌸😊You: `r`n$userPrompt`r`n`r`n")
            $chatBox.AppendText("`r`n`r`n🚀🤖Copilot: `r`n$previousContent`r`n`r`n")
#            $inputBox.Clear()

            # chatBoxの内容を保存
            SaveChatBoxContent -chatBoxContent $chatBox.Text -workOutputPath $workOutputPath

            # Scroll to the end of the chatBox
            $chatBox.SelectionStart = $chatBox.TextLength
            $chatBox.ScrollToCaret()

            # Bring the window to the foreground
            $form.Activate()
            $form.TopMost = $true
            $form.TopMost = $false

            # Set focus to the inputBox
            $inputBox.Focus()

        }

        if ( $defaultuserPromptPath ) {
            $sendMessage.Invoke()
        }

        $resetChat = {
            $chatBox.Clear()
#            $inputBox.Clear()
            $script:previousPromptPath = $null
            $script:previousContentPath = $null
            $script:previousStoppingWordPath = $null
#            [System.Windows.Forms.MessageBox]::Show("Chat has been reset.", "Reset", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

            # Set focus to the inputBox

#            # リセット時の処理にファイル初期化を追加
#            InitializeChatBoxFile -outputPath $outputPath
            # グローバル変数としてファイルパス等を保持
            $global:chatBoxTimeStamp = ""
            $global:chatBoxFileName = ""
            $global:chatBoxFilePath = ""

            $inputBox.Focus()
        }

        $sendButton.Add_Click($sendMessage)
        $resetButton.Add_Click($resetChat)

#        $inputBox.Add_KeyDown({
#            if ($_.Control -and $_.KeyCode -eq "Enter") {
#                $sendMessage.Invoke()
#                $_.SuppressKeyPress = $true
#            }
#        })
#
#        $inputBox.Add_KeyDown({
#            if ($_.Shift -and $_.KeyCode -eq "Enter") {
#                $resetChat.Invoke()
#                $_.SuppressKeyPress = $true
#            }
#        })
#
#        $inputBox.Add_KeyDown({
#            if ($_.Control -and $_.Shift -and $_.KeyCode -eq "Enter") {
#                $resetChat.Invoke()
#                $sendMessage.Invoke()
#                $_.SuppressKeyPress = $true
#            }
#        })
#
#        $inputBox.Add_KeyDown({
#            if ($_.Control -and $_.KeyCode -eq "A") {
#                $_.SuppressKeyPress = $true
#                $this.SelectAll()
#            }
#        })
        $inputBox.Add_KeyDown({
            if ($_.Control -and $_.Shift -and $_.KeyCode -eq "Enter") {
                $resetChat.Invoke()
                $sendMessage.Invoke()
                $_.SuppressKeyPress = $true
            }
            elseif ($_.Shift -and $_.KeyCode -eq "Enter") {
                $resetChat.Invoke()
                $_.SuppressKeyPress = $true
            }
            elseif ($_.Control -and $_.KeyCode -eq "Enter") {
                $sendMessage.Invoke()
                $_.SuppressKeyPress = $true
            }
            elseif ($_.Control -and $_.KeyCode -eq "A") {
                $_.SuppressKeyPress = $true
                $this.SelectAll()
            }
        })

        # Enable Ctrl+A for both chatBox and inputBox
        $chatBox.Add_KeyDown({
            if ($_.Control -and $_.KeyCode -eq "A") {
                $_.SuppressKeyPress = $true
                $this.SelectAll()
            }
        })

        # Set the window state to maximized
        $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized

        # Set focus to the inputBox when the form is shown
        $form.Add_Shown({
            $inputBox.Focus()
        })

        $form.ShowDialog()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) )", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}