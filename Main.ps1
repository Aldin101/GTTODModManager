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

$tutorial = $false
if (!(test-path "$env:appdata\GTTOD Mod Manager\config.json")) {
    New-Item -ItemType Directory -Path "$env:appdata\GTTOD Mod Manager" | Out-Null
    $global:config = @{
        "glow" = $true
        "backgrounds" = $true
        "gamePath" = findGamePath
    }
    $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
    $tutorial = $true
} else {
    try {
        $global:config = Get-Content "$env:appdata\GTTOD Mod Manager\config.json" | ConvertFrom-Json
    } catch {
        $global:config = @{
            "glow" = $true
            "backgrounds" = $true
            "gamePath" = findGamePath
        }
        $config | ConvertTo-Json | Set-Content "$env:appdata\GTTOD Mod Manager\config.json"
        $tutorial = $true
    }
}

. .\Glow.ps1

$menu = New-Object System.Windows.Window
$menu.Title = "GTTOD Mod Manager"
$menu.Width = 1280
$menu.Height = 720
#$menu.ResizeMode = "NoResize"
$menu.WindowStartupLocation = "CenterScreen"

$menuGrid = New-Object System.Windows.Controls.Grid
$menuGrid.Background = [System.Windows.Media.Brushes]::Transparent
$menu.Content = $menuGrid

setMenuImageMp4 ".\Assets\placeholder.mp4"

if (Test-Path "$env:appdata\Steam Cloudify for Get To The Orange Door\") {
    taskkill /f /im "Get To The Orange Door Game.exe" 2>$null | out-null
} else {
    taskkill /f /im "Get To The Orange Door.exe" 2>$null | out-null
}

$bringBackToFrontTimer = New-Object System.Windows.Forms.Timer
$bringBackToFrontTimer.Interval = 100
$bringBackToFrontTimer.Add_Tick({
    $menuGrid.Children.Remove($backButton)
    $menuGrid.Children.Add($backButton)

    $menuGrid.Children.Remove($settingsButton)
    $menuGrid.Children.Add($settingsButton)
})
$bringBackToFrontTimer.Start()

setMenuImageMp4 ".\Assets\Backgrounds\MainMenu.mp4"
mainMenu

$menu.ShowDialog()