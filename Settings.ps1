function settings {

    foreach ($control in $menuGrid.Children) {
        if ($control.Visibility -eq "Hidden") {
            $control.Name = "AlreadyHidden"
        }

        $control.Visibility = "Hidden"
    }

    $backButton.Visibility = "Visible"

    $global:settingsLabel = New-Object System.Windows.Controls.Label
    $settingsLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $settingsLabel.Content = "Settings"
    $settingsLabel.Foreground = [System.Windows.Media.Brushes]::White
    $settingsLabel.Background = [System.Windows.Media.Brushes]::Transparent
    $settingsLabel.FontFamily = $chakraPetch
    $settingsLabel.FontSize = 20
    $settingsLabel.FontWeight = [System.Windows.FontWeights]::Bold
    $settingsLabel.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Center
    $settingsLabel.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Center
    $settingsLabel.Effect = $menuLabel.Effect
    $menuGrid.Children.Add($settingsLabel)

    $global:graphicsLabel = New-Object System.Windows.Controls.Label
    $graphicsLabel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $graphicsLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $graphicsLabel.Margin = New-Object System.Windows.Thickness(220, 40, 0, 0)
    $graphicsLabel.Width = 200
    $graphicsLabel.Content = "Graphics"
    $graphicsLabel.FontFamily = $chakraPetch
    $graphicsLabel.FontSize = 18
    $graphicsLabel.Foreground = [System.Windows.Media.Brushes]::White
    $graphicsLabel.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Center
    $graphicsLabel.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Center
    $graphicsLabel.Effect = $settingsLabel.Effect
    $menuGrid.Children.Add($graphicsLabel)


    $global:glowCheckbox = New-Object System.Windows.Controls.CheckBox
    $glowCheckbox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $glowCheckbox.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $glowCheckbox.Margin = New-Object System.Windows.Thickness(22, 80, 0, 0)
    $glowCheckbox.Width = 200
    $glowCheckbox.Height = 30
    $glowCheckbox.Content = "Glow"
    $glowCheckbox.FontFamily = $chakraPetch
    $glowCheckbox.FontSize = 14
    $glowCheckbox.Foreground = [System.Windows.Media.Brushes]::White
    $glowCheckbox.IsChecked = $config.glow

    $glowCheckbox.Add_Checked({
        $global:config.glow = $true
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"

        . .\Glow.ps1

        mainMenu $true
    })

    $glowCheckbox.Add_Unchecked({
        $global:config.glow = $false
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"

        foreach ($control in $menuGrid.Children) {
            $control.Effect = $null
            foreach ($child in $control.Items.Children) {
                $child.Effect = $null
            }
        }

        . .\Glow.ps1
    })

    $glowCheckbox.Effect = $settingsLabel.Effect
    $menuGrid.Children.Add($glowCheckbox)

    $global:backgroundsCheckbox = New-Object System.Windows.Controls.CheckBox
    $backgroundsCheckbox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $backgroundsCheckbox.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $backgroundsCheckbox.Margin = New-Object System.Windows.Thickness(22, 110, 0, 0)
    $backgroundsCheckbox.Width = 200
    $backgroundsCheckbox.Height = 30
    $backgroundsCheckbox.Content = "Backgrounds"
    $backgroundsCheckbox.FontFamily = $chakraPetch
    $backgroundsCheckbox.FontSize = 14
    $backgroundsCheckbox.Foreground = [System.Windows.Media.Brushes]::White
    $backgroundsCheckbox.IsChecked = $config.backgrounds

    $backgroundsCheckbox.Add_Checked({
        $global:config.backgrounds = $true
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
    
        setMenuImageMp4 ".\Assets\Backgrounds\MainMenu.mp4"
        $background.Play()
        $menu.Background = $backgroundVisualBrush
    })

    $backgroundsCheckbox.Add_Unchecked({
        $global:config.backgrounds = $false
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"

        $background.Stop()
        $menu.Background = [System.Windows.Media.Brushes]::Black
    })

    $backgroundsCheckbox.Effect = $settingsLabel.Effect
    $menuGrid.Children.Add($backgroundsCheckbox)

    $global:gamePathLabel = New-Object System.Windows.Controls.Label
    $gamePathLabel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $gamePathLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $gamePathLabel.Margin = New-Object System.Windows.Thickness(220, 140, 0, 0)
    $gamePathLabel.Width = 200
    $gamePathLabel.Content = "Game Path"
    $gamePathLabel.FontFamily = $chakraPetch
    $gamePathLabel.FontSize = 18
    $gamePathLabel.Foreground = [System.Windows.Media.Brushes]::White
    $gamePathLabel.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Center
    $gamePathLabel.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Center
    $gamePathLabel.Effect = $settingsLabel.Effect
    $menuGrid.Children.Add($gamePathLabel)

    $global:gamePathTextBox = New-Object System.Windows.Controls.TextBox
    $gamePathTextBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $gamePathTextBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $gamePathTextBox.Margin = New-Object System.Windows.Thickness(22, 180, 0, 0)
    $gamePathTextBox.Width = 600
    $gamePathTextBox.Height = 30
    $gamePathTextBox.FontFamily = $chakraPetch
    $gamePathTextBox.FontSize = 14
    $gamePathTextBox.Foreground = [System.Windows.Media.Brushes]::White
    $gamePathTextBox.Background = [System.Windows.Media.Brushes]::Transparent
    $gamePathTextBox.BorderBrush = [System.Windows.Media.Brushes]::White
    $gamePathTextBox.CaretBrush = [System.Windows.Media.Brushes]::White
    $gamePathTextBox.Text = $config.gamePath
    $gamePathTextBox.Effect = $settingsLabel.Effect

    $gamePathTextBox.Add_TextChanged({
        if (!(Test-Path "$($gamePathTextBox.Text)Get To The Orange Door.exe")) {
            $gamePathTextBox.Foreground = [System.Windows.Media.Brushes]::Red
            return;
        } else {
            $gamePathTextBox.Foreground = [System.Windows.Media.Brushes]::LightGreen
        }

        $global:config.gamePath = $gamePathTextBox.Text
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
    })
    $menuGrid.Children.Add($gamePathTextBox)

    $global:gameOptionsLabel = New-Object System.Windows.Controls.Label
    $gameOptionsLabel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $gameOptionsLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $gameOptionsLabel.Margin = New-Object System.Windows.Thickness(220, 220, 0, 0)
    $gameOptionsLabel.Width = 200
    $gameOptionsLabel.Content = "Game Options"
    $gameOptionsLabel.FontFamily = $chakraPetch
    $gameOptionsLabel.FontSize = 18
    $gameOptionsLabel.Foreground = [System.Windows.Media.Brushes]::White
    $gameOptionsLabel.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Center
    $gameOptionsLabel.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Center
    $gameOptionsLabel.Effect = $settingsLabel.Effect
    $menuGrid.Children.Add($gameOptionsLabel)

    $global:consoleCheckBox = New-Object System.Windows.Controls.CheckBox
    $consoleCheckBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $consoleCheckBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $consoleCheckBox.Margin = New-Object System.Windows.Thickness(22, 260, 0, 0)
    $consoleCheckBox.Width = 200
    $consoleCheckBox.Height = 30
    $consoleCheckBox.Content = "Console"
    $consoleCheckBox.FontFamily = $chakraPetch
    $consoleCheckBox.FontSize = 14
    $consoleCheckBox.Foreground = [System.Windows.Media.Brushes]::White
    $consoleCheckBox.Effect = $settingsLabel.Effect

    if ($gameConfig -ne $null) {
        if ($gameConfig."Logging.Console".Enabled -eq "false") {
            $consoleCheckBox.IsChecked = $false
        } else {
            $consoleCheckBox.IsChecked = $true
        }
    } else {
        $consoleCheckBox.IsChecked = $false
        $consoleCheckBox.IsEnabled = $false
    }

    $consoleCheckBox.Add_Checked({
        $global:gameConfig."Logging.Console".Enabled = "true"
        Write-IniContent "$env:appdata\GTTOD Mod Manager\BepInEx.cfg" $gameConfig
        Copy-Item "$env:appdata\GTTOD Mod Manager\BepInEx.cfg" "$($config.gamePath)BepInEx\config\BepInEx.cfg" -Force
    })

    $consoleCheckBox.Add_Unchecked({
        $global:gameConfig."Logging.Console".Enabled = "false"
        Write-IniContent "$env:appdata\GTTOD Mod Manager\BepInEx.cfg" $gameConfig
        Copy-Item "$env:appdata\GTTOD Mod Manager\BepInEx.cfg" "$($config.gamePath)BepInEx\config\BepInEx.cfg" -Force
    })
    $menuGrid.Children.Add($consoleCheckBox)
}