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

    # Create a new ListBox
    $global:listBox = New-Object System.Windows.Controls.ListBox
    $listBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
    $listBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
    $listBox.Margin = New-Object System.Windows.Thickness(0, 30, 0, 0)
    $listBox.Background = [System.Windows.Media.Brushes]::Transparent
    $listBox.Foreground = [System.Windows.Media.Brushes]::White
    $listBox.FontFamily = $chakraPetch
    $listBox.FontSize = 12
    $listBox.BorderThickness = New-Object System.Windows.Thickness(0)

    $listBox.Add_SelectionChanged({
        param($sender, $e)
    
        if ($sender.SelectedIndex -eq -1) {
            return
        }

        if ($sender.Items[$sender.SelectedIndex].children[0].IsChecked -eq $null) {
            $sender.UnselectAll()
            return
        }
    
        # Get the selected mod
        $selectedMod = $sender.Items[$sender.SelectedIndex].children[1].Content
    
        # Find the mod in the mods array
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
    
        # Check if the mod has any dependencies
        if ($mod.Dependencies) {
            # Iterate over the dependencies
            foreach ($dependency in $mod.Dependencies) {
                # Find the checkbox for the dependency
                $dependencyCheckBox = $null
                for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
                    if ($listBox.Items[$i].children[1].Content -eq $dependency) {
                        $dependencyCheckBox = $listBox.Items[$i].children[0]
                        break
                    }
                }
    
                # Check the checkbox for the dependency
                if ($dependencyCheckBox -ne $null) {
                    $dependencyCheckBox.IsChecked = $true
                }
            }
        }
    
        # If unchecking a mod, check if any other mods depend on it
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

        # Toggle the checkbox for the selected mod
        $sender.Items[$sender.SelectedIndex].children[0].IsChecked = !$sender.Items[$sender.SelectedIndex].children[0].IsChecked
        $sender.UnselectAll()
    })

    # Create a StackPanel for the headers
    $headerPanel = New-Object System.Windows.Controls.StackPanel
    $headerPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

    # Create a Label for the Install header
    $installHeader = New-Object System.Windows.Controls.Label
    $installHeader.Content = "Install"
    $installHeader.Foreground = [System.Windows.Media.Brushes]::White
    $installHeader.Effect = $orangeGlow
    $installHeader.Margin = New-Object System.Windows.Thickness(0, 0, 0, 0)  # Adjust the right margin

    # Create a Label for the Mod Name header
    $nameHeader = New-Object System.Windows.Controls.Label
    $nameHeader.Content = "Mod Name"
    $nameHeader.Foreground = [System.Windows.Media.Brushes]::White
    $nameHeader.Effect = $orangeGlow
    $nameHeader.Margin = New-Object System.Windows.Thickness(0, 0, 40, 0)  # Adjust the right margin

    $yourVersionHeader = New-Object System.Windows.Controls.Label
    $yourVersionHeader.Content = "Your Version"
    $yourVersionHeader.Foreground = [System.Windows.Media.Brushes]::White
    $yourVersionHeader.Effect = $orangeGlow

    $latestVersionHeader = New-Object System.Windows.Controls.Label
    $latestVersionHeader.Content = "Latest Version"
    $latestVersionHeader.Foreground = [System.Windows.Media.Brushes]::White
    $latestVersionHeader.Effect = $orangeGlow

    # Create a Label for the Mod Description header
    $descriptionHeader = New-Object System.Windows.Controls.Label
    $descriptionHeader.Content = "Mod Description"
    $descriptionHeader.Foreground = [System.Windows.Media.Brushes]::White
    $descriptionHeader.Effect = $orangeGlow

    # Add the Labels to the headerPanel
    $headerPanel.Children.Add($installHeader)
    $headerPanel.Children.Add($nameHeader)
    $headerPanel.Children.Add($yourVersionHeader)
    $headerPanel.Children.Add($latestVersionHeader)
    $headerPanel.Children.Add($descriptionHeader)

    # Add the headerPanel to the ListBox
    $listBox.Items.Add($headerPanel)

    # Add the mods to the ListBox
    foreach ($category in $mods) {
        # Create a StackPanel for the category
        $stackPanel = New-Object System.Windows.Controls.StackPanel
        $stackPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        # Create a Label for the Category Name
        $cat = New-Object System.Windows.Controls.Label
        $cat.Content = $category[0]
        $cat.Foreground = [System.Windows.Media.Brushes]::White
        $cat.Effect = $orangeGlow
        $cat.Width = 600
        $cat.FontSize = 20
        $cat.FontWeight = [System.Windows.FontWeights]::Bold

        # Add the Label to the StackPanel
        $stackPanel.Children.Add($cat)

        # Add the StackPanel to the ListBox
        $listBox.Items.Add($stackPanel)

        # Add the mods to the ListBox
        foreach ($mod in $category[1..$category.Length]) {
            # Create a StackPanel for each mod
            $stackPanel = New-Object System.Windows.Controls.StackPanel
            $stackPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

            # Create a CheckBox for the Install option
            $checkBox = New-Object System.Windows.Controls.CheckBox
            $checkBox.Foreground = [System.Windows.Media.Brushes]::White
            $checkBox.Effect = $orangeGlow
            $checkBox.Margin = New-Object System.Windows.Thickness(10, 5, 25, 0)  # Adjust the top and right margins
            $checkBox.IsEnabled = $false

            # Create a Label for the Mod Name
            $label1 = New-Object System.Windows.Controls.Label
            $label1.Content = $mod.Name
            $label1.Foreground = [System.Windows.Media.Brushes]::White
            $label1.Effect = $orangeGlow
            $label1.Width = 120

            # Create a Label for the Current Version
            $label3 = New-Object System.Windows.Controls.Label
            $label3.Content = (Get-ChildItem ($config.gamePath + $mod.VersionInfoFile) | Select -Expand VersionInfo).FileVersion
            $label3.Foreground = [System.Windows.Media.Brushes]::White
            $label3.Effect = $orangeGlow
            $label3.Width = 87

            if (Test-Path ($config.gamePath + $mod.VersionInfoFile)) {
                if ($label3.Content -eq $mod.Version) {
                    $label3.Foreground = [System.Windows.Media.Brushes]::LightGreen
                } else {
                    $label3.Foreground = [System.Windows.Media.Brushes]::Red
                    $label3.Effect = $redGlow
                }
                $checkBox.IsChecked = $true
            } else {
                $label3.Content = ""
                $checkBox.IsChecked = $false
            }


            # Create a Label for the Latest Version
            $label4 = New-Object System.Windows.Controls.Label
            $label4.Content = $mod.Version
            $label4.Foreground = [System.Windows.Media.Brushes]::White
            $label4.Effect = $orangeGlow
            $label4.Width = 60

            # Create a Label for the Mod Description
            $label2 = New-Object System.Windows.Controls.Label
            $label2.Content = $mod.Description
            $label2.Foreground = [System.Windows.Media.Brushes]::White
            $label2.Effect = $orangeGlow

            # Add the CheckBox and Labels to the StackPanel
            $stackPanel.Children.Add($checkBox)
            $stackPanel.Children.Add($label1)
            $stackPanel.Children.Add($label3)
            $stackPanel.Children.Add($label4)
            $stackPanel.Children.Add($label2)
    
            # Add the StackPanel to the ListBox
            $listBox.Items.Add($stackPanel)
        }
    }

    # Add the ListBox to the menuGrid
    $menuGrid.Children.Add($listBox)

    # Create an "Install or Update" button
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
        $sender.IsEnabled = $false
        $sender.Content = "Working..."

        # Iterate over the items in the ListBox
        for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
            # Get the mod name
            if ($listBox.Items[$i].children[0].IsChecked -eq $null) {
                continue
            }

            $modName = $listBox.Items[$i].children[1].Content
    
            # Find the mod in the mods array
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

            # Check if the mod is checked
            if ($listBox.Items[$i].children[0].IsChecked) {
                # Call install-mod
                install-mod $mod.name $mod.Download $config.gamePath
            } else {
                # Call uninstall-mod
                uninstall-mod $mod.Files $config.gamePath
            }
        }
        mainMenu
    })

    # Add the "Install or Update" button to the menuGrid
    $menuGrid.Children.Add($installButton)

    if ($tutorial) {
        $tutorialMessages = @(
            "Welcome to the GTTOD Mod Manager",
            "This utility provides you with the ability to modify your GTTOD experience to your liking",
            "To begin, select a mod that piques your interest",
            "Afterwards, click on Install or Update to apply your selected modifications",
            "If you wish to remove all your mods, simply deselect 'BepInEx' and click on Install or Update"
        )

        tutorial $tutorialMessages $orangeGlow
    }
}