if ($config.glow) {
    $global:blueGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $blueGlow.Color = 'LightBlue'
    $blueGlow.ShadowDepth = 0
    $blueGlow.BlurRadius = 20
    $blueGlow.Opacity = 1
    $blueGlow.RenderingBias = "Performance"

    $global:redGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $redGlow.Color = 'Red'
    $redGlow.ShadowDepth = 0
    $redGlow.BlurRadius = 20
    $redGlow.Opacity = 1
    $redGlow.RenderingBias = "Performance"

    $global:pinkGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $pinkGlow.Color = 'Pink'
    $pinkGlow.ShadowDepth = 0
    $pinkGlow.BlurRadius = 20
    $pinkGlow.Opacity = 1
    $pinkGlow.RenderingBias = "Performance"

    $global:purpleGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $purpleGlow.Color = 'DarkOrchid'
    $purpleGlow.ShadowDepth = 0
    $purpleGlow.BlurRadius = 20
    $purpleGlow.Opacity = 1
    $purpleGlow.RenderingBias = "Performance"

    $global:orangeGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $orangeGlow.Color = 'Orange'
    $orangeGlow.ShadowDepth = 0
    $orangeGlow.BlurRadius = 20
    $orangeGlow.Opacity = 1
    $orangeGlow.RenderingBias = "Performance"

    $global:blackGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $blackGlow.Color = 'Black'
    $blackGlow.ShadowDepth = 0
    $blackGlow.BlurRadius = 20
    $blackGlow.Opacity = 1
    $blackGlow.RenderingBias = "Performance"

    $global:yellowGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $yellowGlow.Color = 'Yellow'
    $yellowGlow.ShadowDepth = 0
    $yellowGlow.BlurRadius = 20
    $yellowGlow.Opacity = 1
    $yellowGlow.RenderingBias = "Performance"
} else {
    $global:blueGlow = $null
    $global:redGlow = $null
    $global:pinkGlow = $null
    $global:purpleGlow = $null
    $global:orangeGlow = $null
    $global:blackGlow = $null
    $global:yellowGlow = $null
}