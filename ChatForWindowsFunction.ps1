Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. ./WriteParametersFunction.ps1
. ./ProcessOutputPathFunction.ps1
. ./TaskFunction.ps1

function ChatForWindows {
    param(
        [string]$dummy,
        [string]$configPath = "./configure.json",
        [string[]]$previousPromptPath,
        [string[]]$previousContentPath,
        [string[]]$systemPromptPath,
        [string[]]$assistantPromptPath,
        [string]$outputPath
    )

    try {
        WriteParameters -FunctionName $MyInvocation.MyCommand.Name -Parameters $PSBoundParameters
        $config = Get-Content $configPath | Out-String | ConvertFrom-Json
        $chatName = $config.chatName
        $minimizeAndWait = $config.minimizeAndWait
        $userPromptFileName = $config.userPromptFileName
        $previousPromptFileName = $config.previousPromptFileName
        $previousContentFileName = $config.previousContentFileName

        # Initialize script-scoped variables
        $script:previousPromptPath = $previousPromptPath
        $script:previousContentPath = $previousContentPath

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

        $sendMessage = {
            $userPrompt = $inputBox.Text
            if ([string]::IsNullOrWhiteSpace($userPrompt)) { return }

            $workOutputPath = ProcessOutputPath -outputPath $outputPath
            $userPromptPath = $workOutputPath + $userPromptFileName
            $userPrompt | Out-File -FilePath $userPromptPath -Encoding Unicode

            # Minimize the window
            if ( $minimizeAndWait ) {
                $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
            }

#            # Move focus to the previous window
#            [System.Windows.Forms.SendKeys]::SendWait("%{TAB}")

            Task -previousPromptPath $script:previousPromptPath -previousContentPath $script:previousContentPath -systemPromptPath $systemPromptPath -userPromptPath $userPromptPath -assistantPromptPath $assistantPromptPath -outputPath $workOutputPath

            # アシスタントプロンプトの読み込み例
            foreach ($path in $assistantPromptPath) {
              $assistantPrompt += $(Get-Content $path | Out-String )
            }
            $previousContent = $assistantPrompt

            $script:previousPromptPath = $workOutputPath + $previousPromptFileName
            $script:previousContentPath = $workOutputPath + $previousContentFileName
            $previousContent += Get-Content $script:previousContentPath | Out-String

            $chatBox.AppendText("`r`n`r`nYou: $userPrompt`r`n`r`n")
            $chatBox.AppendText("`r`n`r`nCopilot: $previousContent`r`n`r`n")
#            $inputBox.Clear()

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

        $resetChat = {
            $chatBox.Clear()
#            $inputBox.Clear()
            $script:previousPromptPath = $null
            $script:previousContentPath = $null
#            [System.Windows.Forms.MessageBox]::Show("Chat has been reset.", "Reset", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

            # Set focus to the inputBox
            $inputBox.Focus()
        }

        $sendButton.Add_Click($sendMessage)
        $resetButton.Add_Click($resetChat)

        $inputBox.Add_KeyDown({
            if ($_.Control -and $_.KeyCode -eq "Enter") {
                $sendMessage.Invoke()
                $_.SuppressKeyPress = $true
            }
        })

        $inputBox.Add_KeyDown({
            if ($_.Shift -and $_.KeyCode -eq "Enter") {
                $resetChat.Invoke()
                $_.SuppressKeyPress = $true
            }
        })

        $inputBox.Add_KeyDown({
            if ($_.Control -and $_.Shift -and $_.KeyCode -eq "Enter") {
                $resetChat.Invoke()
                $sendMessage.Invoke()
                $_.SuppressKeyPress = $true
            }
        })

        # Enable Ctrl+A for both chatBox and inputBox
        $chatBox.Add_KeyDown({
            if ($_.Control -and $_.KeyCode -eq "A") {
                $_.SuppressKeyPress = $true
                $this.SelectAll()
            }
        })

        $inputBox.Add_KeyDown({
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