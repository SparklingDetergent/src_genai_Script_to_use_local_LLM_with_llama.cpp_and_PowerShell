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
        $userPromptFileName = $config.userPromptFileName
        $previousPromptFileName = $config.previousPromptFileName
        $previousContentFileName = $config.previousContentFileName

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Chat for Windows"
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

        $ctrlEnterLabel = New-Object System.Windows.Forms.Label
        $ctrlEnterLabel.Text = "Press Ctrl + Enter to send"
        $ctrlEnterLabel.AutoSize = $true
        $form.Controls.Add($ctrlEnterLabel)

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

            Task -previousPromptPath $previousPromptPath -previousContentPath $previousContentPath -systemPromptPath $systemPromptPath -userPromptPath $userPromptPath -assistantPromptPath $assistantPromptPath -outputPath $workOutputPath

            $previousPromptPath = $workOutputPath + $previousPromptFileName
            $previousContentPath = $workOutputPath + $previousContentFileName
            $previousContent = Get-Content $previousContentPath | Out-String

            $chatBox.AppendText("You: $userPrompt`r`n")
            $chatBox.AppendText("Copilot: $previousContent`r`n`r`n")
            $inputBox.Clear()
        }

        $sendButton.Add_Click($sendMessage)

        $inputBox.Add_KeyDown({
            if ($_.Control -and $_.KeyCode -eq "Enter") {
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

        $form.ShowDialog()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("$($_.Exception.ToString()) `r`n : $($_.InvocationInfo.ScriptName) ( $($_.InvocationInfo.ScriptLineNumber) )", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}