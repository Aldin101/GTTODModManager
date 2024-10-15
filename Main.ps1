Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Windows.Media;
using System.Reflection;

public class FontLoader {
    public static FontFamily LoadFont(string fontFilePath) {
        var fontUri = new Uri(fontFilePath);
        return new FontFamily(fontUri, "./#Chakra Petch");
    }
}
"@ -ReferencedAssemblies "WindowsBase", "PresentationCore"

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.Application]::enablevisualstyles()

Add-Type -AssemblyName PresentationFramework,System.Drawing
if ($PSVersionTable.psversion.Major -eq 5) {
    Add-Type -Path "C:\Windows\Microsoft.NET\Framework\v4.0.30319\WPF\WindowsFormsIntegration.dll"
} else {
    Add-Type -Path "C:\Program Files\PowerShell\7\WindowsFormsIntegration.dll"
}

try {
    . .\ModInstaller.ps1
    . .\FindGamePath.ps1
    . .\Settings.ps1
    . .\Tutorial.ps1
    . .\MenuImage.ps1
    . .\IniReader.ps1
    . .\Menu.ps1
} catch {
    [System.Windows.Forms.MessageBox]::Show("An error occurred while loading program modals, please try again.`n`n$_", "GTTOD Mod Manager", "OK", "Error")
    exit
}

try {
    foreach ($font in (Get-ChildItem ".\Assets\Chakra Petch\" -Filter "*.ttf")) {
        $chakraPetch = [FontLoader]::LoadFont($font.FullName)
    }
} catch {
    [System.Windows.Forms.MessageBox]::Show("An error occurred while loading fonts, please try again.`n`n$_", "GTTOD Mod Manager", "OK", "Error")
    exit
}

try {
    $global:mods = ((Invoke-WebRequest -Uri "https://gttodmods.vegapatch.net/mods.json" -UseBasicParsing).Content | ConvertFrom-Json).mods
    # $global:mods = (Get-Content .\Database\mods.json | ConvertFrom-Json).mods
} catch {
    [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the online mod list, please check your internet and try again.`n`n$_", "GTTOD Mod Manager", "OK", "Error")
    exit
}

$global:tutorial = $false
if (!(test-path "$env:appdata\GTTOD Mod Manager\config.json")) {
    New-Item -ItemType Directory -Path "$env:appdata\GTTOD Mod Manager" | Out-Null
    $global:config = @{
        "glow" = $true
        "fancyGlow" = $false
        "backgrounds" = $true
        "gamePath" = findGamePath
    }
    $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
    $global:tutorial = $true
} else {
    try {
        $global:config = Get-Content "$env:appdata\GTTOD Mod Manager\config.json" | ConvertFrom-Json
    } catch {
        $global:config = @{
            "glow" = $true
            "fancyGlow" = $false
            "backgrounds" = $true
            "gamePath" = findGamePath
        }
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
        $global:tutorial = $true
    }
}

if ($config.fancyGlow -eq $null) {
    $global:config = @{
        "glow" = $config.glow
        "fancyGlow" = $false
        "backgrounds" = $config.backgrounds
        "gamePath" = $config.gamePath
    }
    $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
}

. .\Glow.ps1

if (test-path "$($config.gamePath)BepInEx\config\BepInEx.cfg") {
    $global:gameConfig = Get-IniContent "$($config.gamePath)BepInEx\config\BepInEx.cfg"
    Copy-Item "$($config.gamePath)BepInEx\config\BepInEx.cfg" "$env:appdata\GTTOD Mod Manager\BepInEx.cfg" -Force
} else {
    $global:gameConfig = $null
}

$icon = New-Object System.Windows.Media.Imaging.BitmapImage
$icon.BeginInit()
$icon.UriSource = New-Object System.Uri('.\Assets\icon.ico', [System.UriKind]::Relative)
$icon.EndInit()

$menu = New-Object System.Windows.Window
$menu.Title = "GTTOD Mod Manager"
$menu.Width = 1280
$menu.Height = 720
$menu.MinWidth = 645
$menu.MinHeight = 250
$menu.WindowStartupLocation = "CenterScreen"
$menu.Icon = $icon

$menuGrid = New-Object System.Windows.Controls.Grid
$menuGrid.Background = [System.Windows.Media.Brushes]::Transparent
$menu.Content = $menuGrid

$bringBackToFrontTimer = New-Object System.Windows.Forms.Timer
$bringBackToFrontTimer.Interval = 100
$bringBackToFrontTimer.Add_Tick({
    $menuGrid.Children.Remove($backButton)
    $menuGrid.Children.Add($backButton)

    $menuGrid.Children.Remove($settingsButton)
    $menuGrid.Children.Add($settingsButton)

    foreach ($stackPanel in $listBox.Items) {
        if ($stackPanel.children[5].Width -eq $null) {
            continue
        }
        try {
            $stackPanel.children[4].Width = $menu.ActualWidth - 465
        } catch {
            return
        }
    }
})
$bringBackToFrontTimer.Start()

setMenuImageMp4 ".\Assets\Backgrounds\MainMenu.mp4"
mainMenu

$menu.ShowDialog()

$bringBackToFrontTimer.Stop()