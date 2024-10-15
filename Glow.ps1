function Create-GlowEffect($color) {
    $glowEffect = New-Object System.Windows.Media.Effects.DropShadowEffect
    $glowEffect.Color = $color
    $glowEffect.ShadowDepth = 0
    $glowEffect.BlurRadius = 20
    $glowEffect.Opacity = 1
    $glowEffect.RenderingBias = "Performance"
    return $glowEffect
}

if ($config.glow -and !$config.fancyGlow) {
    $Global:gridGlow = New-Object System.Windows.Media.Effects.DropShadowEffect
    $gridGlow.Color = 'Orange'
    $gridGlow.ShadowDepth = 0
    $gridGlow.BlurRadius = 20
    $gridGlow.Opacity = 1
    $gridGlow.RenderingBias = "Performance"
} else {
    $global:gridGlow = $null
}

if ($config.fancyGlow -and $config.glow) {
    $global:blueGlow = Create-GlowEffect 'LightBlue'
    $global:redGlow = Create-GlowEffect 'Red'
    $global:pinkGlow = Create-GlowEffect 'Pink'
    $global:purpleGlow = Create-GlowEffect 'DarkOrchid'
    $global:orangeGlow = Create-GlowEffect 'Orange'
    $global:blackGlow = Create-GlowEffect 'Black'
    $global:yellowGlow = Create-GlowEffect 'Yellow'
} else {
    $global:blueGlow = $null
    $global:redGlow = $null
    $global:pinkGlow = $null
    $global:purpleGlow = $null
    $global:orangeGlow = $null
    $global:blackGlow = $null
    $global:yellowGlow = $null
}