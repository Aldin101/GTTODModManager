function menuImageTick {

    if ($global:gif -eq $null) {
        return
    }

    if (!$menuImageTimer.running) {
        return
    }

    $bitmapSource = $global:gif.Frames[$global:index]

    $imageBrush = New-Object System.Windows.Media.ImageBrush $bitmapSource

    $menu.Background = $imageBrush

    $stopwatch.Stop()
    $elapsedMilliseconds = $stopwatch.ElapsedMilliseconds
    try {
        $framesToSkip = [Math]::Floor($elapsedMilliseconds / $menuImageTimer.Interval)
    } catch {
        $framesToSkip = 1
    }
    $global:index += $framesToSkip
    $stopwatch.Restart()

    if ($global:index -ge $global:frameCount) {
        $global:index = 0
    }
}

function setMenuImage {
    param(
        [string]$image
    )

    if (!$config.backgrounds) {
        $menu.Background = [System.Windows.Media.Brushes]::Black
        return
    }

    if (!(test-path $image)) {
        return
    }

    $global:menuImageTimer.Stop()
    $global:menuImageTimer.Dispose()

    $global:menuImageTimer = New-Object System.Windows.Forms.Timer
    $menuImageTimer.Interval = 20

    $global:gif = [System.Windows.Media.Imaging.BitmapDecoder]::Create(
        [System.IO.FileStream]::new($image, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read),
        [System.Windows.Media.Imaging.BitmapCreateOptions]::None,
        [System.Windows.Media.Imaging.BitmapCacheOption]::Default
    )
    $global:frameCount = $gif.Frames.Count
    $global:index = 0

    $global:stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $menuImageTimer.Add_Tick({
        menuImageTick
    })
    $menuImageTimer.Start()
}

function setMenuImageMp4 {
    param(
        [string]$media
    )

    if (!$config.backgrounds) {
        $menu.Background = [System.Windows.Media.Brushes]::Black
        return
    }

    if (!(test-path $media)) {
        return
    }

    # $menuImageTimer.Stop()

    $global:background = New-Object System.Windows.Controls.MediaElement
    $background.Source = New-Object System.Uri((Resolve-Path $media))
    $background.LoadedBehavior = [System.Windows.Controls.MediaState]::Manual
    $background.UnloadedBehavior = [System.Windows.Controls.MediaState]::Close
    $background.Add_MediaEnded({ $background.Position = [TimeSpan]::Zero })
    $background.Play()

    $grid = New-Object System.Windows.Controls.Grid
    $grid.Children.Add($background)
    $grid.Opacity = 0.25

    $global:backgroundVisualBrush = New-Object System.Windows.Media.VisualBrush $grid

    if (!$loopTimer.Enabled) {
        $menu.Background = $backgroundVisualBrush
    }
}