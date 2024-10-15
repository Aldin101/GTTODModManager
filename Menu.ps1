function clearMenuObjects {
    $menuGrid.Children.Clear()

    $global:backButton = New-Object System.Windows.Controls.Button
    $backButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $backButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $backButton.Margin = New-Object System.Windows.Thickness(0, 0, 0, 0)
    $backButton.Width = 100
    $backButton.Height = 30
    $backButton.Background = [System.Windows.Media.Brushes]::Black
    $backButton.Foreground = [System.Windows.Media.Brushes]::White
    $backButton.Content = "Back"
    $backButton.FontFamily = $chakraPetch
    $backButton.FontSize = 12
    $backButton.Cursor = [System.Windows.Input.Cursors]::Hand
    $backButton.Add_Click({
        back
    })
    $menuGrid.Children.Add($backButton)

    $global:settingsButton = New-Object System.Windows.Controls.Button
    $settingsButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $settingsButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $settingsButton.Margin = New-Object System.Windows.Thickness(0, 0, 0, 0)
    $settingsButton.Width = 30
    $settingsButton.Height = 30
    $settingsButton.Background = [System.Windows.Media.Brushes]::Black
    $settingsButton.Foreground = [System.Windows.Media.Brushes]::White
    $settingsButton.Content = "⚙️"
    $settingsButton.FontFamily = $chakraPetch
    $settingsButton.FontSize = 12
    $settingsButton.Cursor = [System.Windows.Input.Cursors]::Hand
    $settingsButton.Add_Click({
        settings
    })
    $menuGrid.Children.Add($settingsButton)
}

function back {
    if ($menuGrid.Children -contains $settingsLabel) {
        $controlsToRemove = New-Object System.Collections.Generic.List[System.Windows.UIElement]

        foreach ($control in $menuGrid.Children) {
            if ($control.Visibility -eq [System.Windows.Visibility]::Visible) {
                $controlsToRemove.Add($control)
            } elseif ($control.Name -ne "AlreadyHidden") {
                $control.Visibility = [System.Windows.Visibility]::Visible
            }
        }

        foreach ($control in $controlsToRemove) {
            $menuGrid.Children.Remove($control)
        }

        if ($global:menuLabel.Content -eq "GTTOD Mod Manager") {
            $backButton.Visibility = "Hidden"
        }

        return
    }

    mainMenu
}

function buttonBackgroundImage {
    param (
        $image,
        $control
    )

    if (!(test-path $image)) {
        return
    }

    $imageSource = New-Object System.Windows.Media.Imaging.BitmapImage
    $imageSource.BeginInit()
    $imageSource.UriSource = New-Object System.Uri((Resolve-Path $image))
    $imageSource.EndInit()

    $imageBrush = New-Object System.Windows.Media.ImageBrush
    $imageBrush.ImageSource = $imageSource

    $control.Background = $imageBrush

    $style = New-Object System.Windows.Style -ArgumentList ([System.Windows.Controls.Button])
    $template = New-Object System.Windows.Controls.ControlTemplate -ArgumentList ([System.Windows.Controls.Button])

    $frameworkElementFactory = New-Object System.Windows.FrameworkElementFactory([System.Windows.Controls.Border])
    $frameworkElementFactory.SetValue([System.Windows.Controls.Control]::CursorProperty, [System.Windows.Input.Cursors]::Hand)
    $frameworkElementFactory.SetValue([System.Windows.Controls.Control]::BackgroundProperty, $imageBrush)

    $template.VisualTree = $frameworkElementFactory
    $style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::TemplateProperty, $template)))

    $control.Style = $style

    return $style
}
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split '\n' |
    % {
        if ($_ -match '[\}\]]') {
            $indent--
        }
        $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
        if ($_ -match '[\{\[]') {
            $indent++
        }
        $line
    }) -Join "`n"
}
function mainMenu {
    param(
        [bool]$loadSettings = $false
    )
    clearMenuObjects

    $backButton.Visibility = "Hidden"

    $global:menuLabel = New-Object System.Windows.Controls.Label
    $menuLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $menuLabel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $menuLabel.Content = "GTTOD Mod Manager"
    $menuLabel.Foreground = [System.Windows.Media.Brushes]::White
    $menuLabel.Background = [System.Windows.Media.Brushes]::Transparent
    $menuLabel.FontFamily = $chakraPetch
    $menuLabel.FontSize = 20
    $menuLabel.FontWeight = [System.Windows.FontWeights]::Bold
    $menuLabel.Effect = $orangeGlow
    $menuGrid.Children.Add($menuLabel)

    $global:listBox = New-Object System.Windows.Controls.ListBox
    $listBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
    $listBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
    $listBox.Margin = New-Object System.Windows.Thickness(0, 30, 0, 0)
    $listBox.Background = [System.Windows.Media.Brushes]::Transparent
    $listBox.Foreground = [System.Windows.Media.Brushes]::White
    $listBox.FontFamily = $chakraPetch
    $listBox.FontSize = 12
    $listBox.BorderThickness = New-Object System.Windows.Thickness(0)
    [System.Windows.Controls.ScrollViewer]::SetCanContentScroll($listBox, $false)

    $listBox.Add_SelectionChanged({
        param($sender, $e)

        if ($sender.SelectedIndex -eq -1) {
            return
        }

        if ($sender.Items[$sender.SelectedIndex].children[0].IsChecked -eq $null) {
            $sender.UnselectAll()
            return
        }

        $selectedMod = $sender.Items[$sender.SelectedIndex].children[1].Content

        $mod = $null
        foreach ($category in $mods) {
            foreach ($modInCategory in $category[1..$category.Length]) {
                if ($modInCategory.Name -eq $selectedMod) {
                    $mod = $modInCategory
                    break
                }
            }
            if ($mod -ne $null) {
                break
            }
        }

        if ($mod.Deprecated) {
            [System.Windows.Forms.MessageBox]::Show("This mod is deprecated and is no longer supported.", "GTTOD Mod Manager", "OK", "Warning")
            $sender.UnselectAll()
            return
        }

        if ($mod.Dependencies) {
            foreach ($dependency in $mod.Dependencies) {
                $dependencyCheckBox = $null
                for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
                    if ($listBox.Items[$i].children[1].Content -eq $dependency) {
                        $dependencyCheckBox = $listBox.Items[$i].children[0]
                        break
                    }
                }

                if ($dependencyCheckBox -ne $null) {
                    $dependencyCheckBox.IsChecked = $true
                }
            }
        }

        if ($sender.Items[$sender.SelectedIndex].children[0].IsChecked) {
            for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
                if ($listBox.Items[$i].children[0].IsChecked) {
                    $modName = $listBox.Items[$i].children[1].Content
                    $mod = $null
                    foreach ($category in $mods) {
                        foreach ($modInCategory in $category[1..$category.Length]) {
                            if ($modInCategory.Name -eq $modName) {
                                $mod = $modInCategory
                                break
                            }
                        }
                        if ($mod -ne $null) {
                            break
                        }
                    }
                    if ($mod.Dependencies -contains $selectedMod) {
                        $listBox.Items[$i].children[0].IsChecked = $false
                    }
                }
            }
        }

        $sender.Items[$sender.SelectedIndex].children[0].IsChecked = !$sender.Items[$sender.SelectedIndex].children[0].IsChecked
        $sender.UnselectAll()
    })

    $headerPanel = New-Object System.Windows.Controls.StackPanel
    $headerPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

    $installHeader = New-Object System.Windows.Controls.Label
    $installHeader.Content = "Install"
    $installHeader.Foreground = [System.Windows.Media.Brushes]::White
    $installHeader.Effect = $orangeGlow
    $installHeader.Margin = New-Object System.Windows.Thickness(0, 0, 0, 0)

    $nameHeader = New-Object System.Windows.Controls.Label
    $nameHeader.Content = "Mod Name"
    $nameHeader.Foreground = [System.Windows.Media.Brushes]::White
    $nameHeader.Effect = $orangeGlow
    $nameHeader.Margin = New-Object System.Windows.Thickness(0, 0, 83, 0)

    $yourVersionHeader = New-Object System.Windows.Controls.Label
    $yourVersionHeader.Content = "Your Version"
    $yourVersionHeader.Foreground = [System.Windows.Media.Brushes]::White
    $yourVersionHeader.Effect = $orangeGlow

    $latestVersionHeader = New-Object System.Windows.Controls.Label
    $latestVersionHeader.Content = "Latest Version"
    $latestVersionHeader.Foreground = [System.Windows.Media.Brushes]::White
    $latestVersionHeader.Effect = $orangeGlow

    $descriptionHeader = New-Object System.Windows.Controls.Label
    $descriptionHeader.Content = "Mod Description"
    $descriptionHeader.Foreground = [System.Windows.Media.Brushes]::White
    $descriptionHeader.Effect = $orangeGlow

    $headerPanel.Children.Add($installHeader)
    $headerPanel.Children.Add($nameHeader)
    $headerPanel.Children.Add($yourVersionHeader)
    $headerPanel.Children.Add($latestVersionHeader)
    $headerPanel.Children.Add($descriptionHeader)

    $listBox.Items.Add($headerPanel)

    $deprecatedPluginsInstalled = $false

    foreach ($category in $mods) {
        $stackPanel = New-Object System.Windows.Controls.StackPanel
        $stackPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $cat = New-Object System.Windows.Controls.Label
        $cat.Content = $category[0]
        $cat.Foreground = [System.Windows.Media.Brushes]::White
        $cat.Effect = $orangeGlow
        $cat.Width = 600
        $cat.FontSize = 20
        $cat.FontWeight = [System.Windows.FontWeights]::Bold

        $stackPanel.Children.Add($cat)

        $listBox.Items.Add($stackPanel)

        foreach ($mod in $category[1..$category.Length]) {
            $stackPanel = New-Object System.Windows.Controls.StackPanel
            $stackPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

            $checkBox = New-Object System.Windows.Controls.CheckBox
            $checkBox.Foreground = [System.Windows.Media.Brushes]::White
            $checkBox.Effect = $orangeGlow
            $checkBox.Margin = New-Object System.Windows.Thickness(10, 5, 25, 0)
            $checkBox.IsEnabled = $false
            $checkBox.IsChecked = $true

            $modName = New-Object System.Windows.Controls.Label
            $modName.Content = $mod.Name
            $modName.Foreground = [System.Windows.Media.Brushes]::White
            $modName.Effect = $orangeGlow
            $modName.Width = 150

            $yourVersion = New-Object System.Windows.Controls.Label
            $yourVersion.Foreground = [System.Windows.Media.Brushes]::White
            $yourVersion.Effect = $orangeGlow
            $yourVersion.Width = 70
            $yourVersion.HorizontalContentAlignment = "Center"

            $ErrorActionPreference = "SilentlyContinue"
            $yourVersion.Content = (Get-ChildItem ($config.gamePath + $mod.VersionInfoFile) | Select -Expand VersionInfo).FileVersion
            $ErrorActionPreference = "Continue"

            if ($yourVersion.Content -eq $mod.Version) {
                $yourVersion.Foreground = [System.Windows.Media.Brushes]::LightGreen
            } else {
                $yourVersion.Foreground = [System.Windows.Media.Brushes]::Red
                $yourVersion.Effect = $redGlow
            }

            if ($yourVersion.Content -eq "" -or $yourVersion.Content -eq $null -or $mod.Deprecated) {
                $checkBox.IsChecked = $false
            }

            $hasDependent = $false
            foreach ($category in $mods) {
                foreach ($dependentMod in $category[1..$category.Length]) {
                    if (!(Test-Path ($config.gamePath + $dependentMod.VersionInfoFile))) {
                        continue
                    }
                    foreach ($dependency in $dependentMod.Dependencies) {
                        if ($dependency -eq $mod.Name) {
                            $hasDependent = $true
                        }
                    }
                }
            }

            if ($hasDependent -and !$checkBox.IsChecked) {
                $checkBox.IsChecked = $true
                $yourVersion.Content = "Not Installed"
                $yourVersion.FontSize = 10
                $yourVersion.Foreground = [System.Windows.Media.Brushes]::Red
                $yourVersion.Effect = $redGlow
            }

            if ($mod.Deprecated -and $yourVersion.Content -ne "" -and $yourVersion.Content -ne $null) {
                $deprecatedPluginsInstalled = $true
            }

            $latestVersion = New-Object System.Windows.Controls.Label
            $latestVersion.Content = $mod.Version
            $latestVersion.Foreground = [System.Windows.Media.Brushes]::White
            $latestVersion.Effect = $orangeGlow
            $latestVersion.Width = 90
            $latestVersion.HorizontalContentAlignment = "Center"

            $modDescription = New-Object System.Windows.Controls.Label
            $modDescription.Content = $mod.Description
            $modDescription.Foreground = [System.Windows.Media.Brushes]::White
            $modDescription.Effect = $orangeGlow
            $modDescription.Width = $menu.Width - 410

            $moreInfoButton = New-Object System.Windows.Controls.Button
            $moreInfoButton.Content = "More Info"
            $moreInfoButton.Foreground = [System.Windows.Media.Brushes]::White
            $moreInfoButton.Background = [System.Windows.Media.Brushes]::Black
            $moreInfoButton.FontFamily = $chakraPetch
            $moreInfoButton.FontSize = 12
            $moreInfoButton.Cursor = [System.Windows.Input.Cursors]::Hand

            $moreInfoButton.Tag = $mod.MoreInfoLink
            $moreInfoButton.Add_Click({
                param($sender, $e)
                Start-Process $sender.Tag
            })

            if ($mod.MoreInfoLink -eq $null) {
                $moreInfoButton.Visibility = "hidden"
            }

            $listBox.Add_SizeChanged({
                param($sender, $e)

                foreach ($stackPanel in $sender.Items) {
                    if ($stackPanel.children[5].Width -eq $null) {
                        continue
                    }
                    try {
                        $stackPanel.children[4].Width = $menu.Width - 465
                    } catch {
                        return
                    }
                }
            })

            $stackPanel.Children.Add($checkBox)
            $stackPanel.Children.Add($modName)
            $stackPanel.Children.Add($yourVersion)
            $stackPanel.Children.Add($latestVersion)
            $stackPanel.Children.Add($modDescription)
            $stackPanel.Children.Add($moreInfoButton)

            $listBox.Items.Add($stackPanel)

            if ($mod.Deprecated) {
                $yourVersion.Foreground = [System.Windows.Media.Brushes]::Red
                $yourVersion.Effect = $redGlow
                $latestVersion.Content = "Deprecated"
            }
        }
    }

    $menuGrid.Children.Add($listBox)

    $installButton = New-Object System.Windows.Controls.Button
    $installButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $installButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom
    $installButton.Margin = New-Object System.Windows.Thickness(0, 0, 0, 0)
    $installButton.Width = 150
    $installButton.Height = 30
    $installButton.Background = [System.Windows.Media.Brushes]::Black
    $installButton.Foreground = [System.Windows.Media.Brushes]::White
    $installButton.Content = "Install or Update"
    $installButton.FontFamily = $chakraPetch
    $installButton.FontSize = 12
    $installButton.Cursor = [System.Windows.Input.Cursors]::Hand
    $installButton.Add_Click({
        param($sender, $e)
        if (!(Test-Path "$($config.gamePath)Get To The Orange Door.exe")) {
            [System.Windows.Forms.MessageBox]::Show("Game folder not found. Please set the game folder in the settings.", "GTTOD Mod Manager", "OK", "Error")
            return
        }

        if (Get-Process "Get To The Orange Door" -ErrorAction SilentlyContinue) {
            [System.Windows.Forms.MessageBox]::Show("Please close the game before installing or updating mods.", "GTTOD Mod Manager", "OK", "Warning")
            return
        }

        $global:progressBar.Visibility = "Visible"
        $menu.Dispatcher.Invoke([System.Windows.Threading.DispatcherPriority]::Render, [action]{
        })

        for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
            if ($listBox.Items[$i].children[0].IsChecked -eq $null) {
                continue
            }

            $modName = $listBox.Items[$i].children[1].Content

            $mod = $null
            foreach ($category in $mods) {
                foreach ($modInCategory in $category[1..$category.Length]) {
                    if ($modInCategory.Name -eq $modName) {
                        $mod = $modInCategory
                        break
                    }
                }
                if ($mod -ne $null) {
                    break
                }
            }

            if ($listBox.Items[$i].children[0].IsChecked) {
                install-mod $mod.name $mod.Download $config.gamePath
            } else {
                uninstall-mod $mod.Files $config.gamePath
            }

            $global:progressBar.Value = ($i + 1) / $listBox.Items.Count * 100
            $menu.Dispatcher.Invoke([System.Windows.Threading.DispatcherPriority]::Render, [action]{
            })
        }

        if ((test-path "$env:appdata\GTTOD Mod Manager\BepInEx.cfg") -and (test-path "$($config.gamePath)BepInEx\config\")) {
            $global:gameConfig = Get-IniContent "$env:appdata\GTTOD Mod Manager\BepInEx.cfg"
            Copy-Item "$env:appdata\GTTOD Mod Manager\BepInEx.cfg" "$($config.gamePath)BepInEx\config\BepInEx.cfg" -Force
        } elseif (test-path "$($config.gamePath)BepInEx\config\BepInEx.cfg") {
            $global:gameConfig = Get-IniContent "$($config.gamePath)BepInEx\config\BepInEx.cfg"
        }

        mainMenu
    })

    $menuGrid.Children.Add($installButton)

    $global:progressBar = New-Object System.Windows.Controls.ProgressBar
    $progressBar.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $progressBar.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom
    $progressBar.Width = 150
    $progressBar.Height = 30
    $progressBar.Margin = New-Object System.Windows.Thickness(0, 0, 0, 0)
    $progressBar.Background = [System.Windows.Media.Brushes]::Black
    $progressBar.Foreground = [System.Windows.Media.Brushes]::White
    $progressBar.Visibility = "Hidden"

    $menuGrid.Children.Add($progressBar)

    if ($tutorial) {
        $tutorialMessages = @(
            "Welcome to the GTTOD Mod Manager",
            "This utility provides you with the ability to modify your GTTOD experience to your liking",
            "To begin, select a mod that piques your interest",
            "Afterwards, click on Install or Update to apply your selected modifications",
            "If you wish to remove all your mods, simply deselect 'BepInEx' and click on Install or Update"
        )

        tutorial $tutorialMessages $orangeGlow
        $global:tutorial = $false
    }

    if ($loadSettings) {
        settings
    }

    if ($deprecatedPluginsInstalled) {
        $choice = [System.Windows.Forms.MessageBox]::Show("Some of your installed mods are deprecated and are no longer supported. Would you like to remove them?", "GTTOD Mod Manager", "YesNo", "Warning")
        if ($choice -eq "Yes") {
            for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
                if ($listBox.Items[$i].children[0].IsChecked -eq $null) {
                    continue
                }
    
                $modName = $listBox.Items[$i].children[1].Content
    
                $mod = $null
                foreach ($category in $mods) {
                    foreach ($modInCategory in $category[1..$category.Length]) {
                        if ($modInCategory.Name -eq $modName) {
                            $mod = $modInCategory
                            break
                        }
                    }
                    if ($mod -ne $null) {
                        break
                    }
                }
    
                if ($mod.Deprecated) {
                    uninstall-mod $mod.Files $config.gamePath
                }
            }
            mainMenu
        }
    }
}