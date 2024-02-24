function Tutorial {
    param (
        [System.Collections.ArrayList] $global:tutorialMessages,
        $glow
    )

    $errorActionPreference = "SilentlyContinue"
    $animationTimer.Stop()
    $fadeOutTimer.Stop()
    $removeObjectsTimer.Stop()
    $foregroundWindowTimer.Stop()

    $backButton.Visibility = "Hidden"
    $settingsButton.Visibility = "Hidden"
    $errorActionPreference = "Continue"

    $global:tutorialGrid = New-Object System.Windows.Controls.Grid
    $tutorialGrid.Background = [System.Windows.Media.Brushes]::Transparent
    $menuGrid.Children.Add($tutorialGrid)

    $global:dimRectangle = New-Object System.Windows.Shapes.Rectangle
    $dimRectangle.Fill = [System.Windows.Media.Brushes]::Black
    $dimRectangle.Opacity = 0.7

    $tutorialGrid.Children.Add($dimRectangle)

    $global:rectangle = New-Object System.Windows.Shapes.Rectangle
    $rectangle.Fill = [System.Windows.Media.Brushes]::Black
    $rectangle.Width = $menu.Width
    $rectangle.Height = $menu.Height
    $rectangle.HorizontalAlignment = "Center"
    $rectangle.VerticalAlignment = "Center"

    $ellipse = New-Object System.Windows.Shapes.Ellipse
    $ellipse.Width = 700
    $ellipse.Height = 1

    $gradientBrush = New-Object System.Windows.Media.RadialGradientBrush
    $gradientBrush.GradientStops.Add((New-Object System.Windows.Media.GradientStop ([System.Windows.Media.Colors]::Transparent, 0.2)))
    $gradientBrush.GradientStops.Add((New-Object System.Windows.Media.GradientStop ([System.Windows.Media.Colors]::Black, 0.4)))

    $gradientBrush.RadiusX = 0.7
    $gradientBrush.RadiusY = 0.25

    $ellipse.Fill = $gradientBrush

    $rectangle.OpacityMask = $ellipse.Fill

    $global:tutorialText = New-Object System.Windows.Controls.TextBlock
    $tutorialText.TextWrapping = 'Wrap'
    $tutorialText.TextAlignment = 'Center'
    $tutorialText.Text = $tutorialMessages[0]


    $global:tutorialTextLabel = New-Object System.Windows.Controls.Label
    $tutorialTextLabel.Width = 450
    $tutorialTextLabel.Height = 500
    $tutorialTextLabel.Content = $tutorialText
    $tutorialTextLabel.Foreground = [System.Windows.Media.Brushes]::White
    if ($tutorialMessages[0] -eq "Welcome to the GTTOD Mod Manager") {
        $tutorialTextLabel.FontSize = 30
        $tutorialTextLabel.Opacity = 1
        $tutorialTextLabel.Width = 550
    } else {
        $tutorialTextLabel.FontSize = 24
        $tutorialTextLabel.Opacity = 0
        $tutorialTextLabel.Width = 450
    }
    $tutorialTextLabel.FontFamily = $chakraPetch
    $tutorialTextLabel.HorizontalAlignment = "Center"
    $tutorialTextLabel.VerticalAlignment = "Center"
    $tutorialTextLabel.Effect = $glow
    $tutorialTextLabel.VerticalContentAlignment = "Center"
    $tutorialTextLabel.HorizontalContentAlignment = "Center"
    $tutorialGrid.Children.Add($tutorialTextLabel)

    $tutorialGrid.Children.Add($rectangle)

    $global:translateTransform = New-Object System.Windows.Media.TranslateTransform
    $tutorialTextLabel.RenderTransform = $translateTransform

    $global:animationTimer = New-Object System.Windows.Threading.DispatcherTimer
    $animationTimer.Interval = [TimeSpan]::FromMilliseconds(1400)

    $global:counter = 0

    $animationTimer.Add_Tick({
        $backButton.Visibility = "Hidden"
        $settingsButton.Visibility = "Hidden"
        $animationTimer.Interval = [TimeSpan]::FromSeconds(4)
        if ($counter -lt $tutorialMessages.Count) {
            $tutorialText.Text = $tutorialMessages[$counter]

            $fadeIn = New-Object System.Windows.Media.Animation.DoubleAnimation
            $fadeIn.From = 0
            $fadeIn.To = 1
            $fadeIn.BeginTime = [TimeSpan]::Zero
            $fadeIn.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds(1))

            $move = New-Object System.Windows.Media.Animation.DoubleAnimation
            if ($counter % 2 -eq 0) {
                $move.From = -150
                $move.To = 150
            } else {
                $move.From = 150
                $move.To = -150
            }
            $move.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds(4))

            if ($tutorialMessages[$counter] -eq "Welcome to the GTTOD Mod Manager") {
                $move.From = 0
                $move.To = 0
                $fadeIn.From = 1
                $fadeIn.To = 1
                $tutorialTextLabel.FontSize = 30
                $tutorialTextLabel.Width = 550
            } else {
                $tutorialTextLabel.FontSize = 24
                $tutorialTextLabel.Width = 450
                $tutorialTextLabel.Opacity = 0
            }
            $translateTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $move)
            $tutorialTextLabel.BeginAnimation([System.Windows.Controls.Label]::OpacityProperty, $fadeIn)
            $fadeOutTimer.Start()

            $parentWindow = [System.Windows.Window]::GetWindow($menu)

            $windowInteropHelper = New-Object System.Windows.Interop.WindowInteropHelper($parentWindow)
            $handle = $windowInteropHelper.Handle
            
            $foregroundWindowTimer.Start()
            $global:counter++
        } else {
            $animationTimer.Stop()
            $fadeOutTimer.Stop()
            $foregroundWindowTimer.Stop()

            $spotlightZoomWidth = New-Object System.Windows.Media.Animation.DoubleAnimation
            $spotlightZoomWidth.From = $menu.Width
            $spotlightZoomWidth.To = ($menu.Width * 10)
            $spotlightZoomWidth.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds(1))
            $spotlightZoomWidth.BeginTime = [TimeSpan]::Zero

            $spotlightZoomHeight = New-Object System.Windows.Media.Animation.DoubleAnimation
            $spotlightZoomHeight.From = $menu.Height
            $spotlightZoomHeight.To = ($menu.Height * 10)
            $spotlightZoomHeight.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds(1))
            $spotlightZoomHeight.BeginTime = [TimeSpan]::Zero

            $removeRectangleDim = New-Object System.Windows.Media.Animation.DoubleAnimation
            $removeRectangleDim.From = 0.7
            $removeRectangleDim.To = 0
            $removeRectangleDim.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds(1))
            $removeRectangleDim.BeginTime = [TimeSpan]::Zero

            $global:removeObjectsTimer = New-Object System.Windows.Threading.DispatcherTimer
            $removeObjectsTimer.Interval = [TimeSpan]::FromSeconds(1)
            $removeObjectsTimer.Add_Tick({
                $tutorialGrid.Children.Remove($rectangle)
                $tutorialGrid.Children.Remove($dimRectangle)
                $tutorialGrid.Children.Remove($tutorialTextLabel)
                $menuGrid.Children.Remove($tutorialGrid)
                $removeObjectsTimer.Stop()
            })

            $removeObjectsTimer.Start()

            $rectangle.BeginAnimation([System.Windows.Shapes.Rectangle]::WidthProperty, $spotlightZoomWidth)
            $rectangle.BeginAnimation([System.Windows.Shapes.Rectangle]::HeightProperty, $spotlightZoomHeight)
            $dimRectangle.BeginAnimation([System.Windows.Shapes.Rectangle]::OpacityProperty, $removeRectangleDim)

            $settingsButton.Visibility = "Visible"
        }
    })

    $global:fadeOutTimer = New-Object System.Windows.Threading.DispatcherTimer
    $fadeOutTimer.Interval = [TimeSpan]::FromSeconds(3)
    $fadeOutTimer.Add_Tick({
        $fadeOut = New-Object System.Windows.Media.Animation.DoubleAnimation
        $fadeOut.From = 1
        $fadeOut.To = 0
        $tutorialTextLabel.BeginAnimation([System.Windows.Controls.Label]::OpacityProperty, $fadeOut)
        $fadeOutTimer.Stop()
    })

    $global:foregroundWindowTimer = New-Object System.Windows.Threading.DispatcherTimer
    $foregroundWindowTimer.Interval = [TimeSpan]::FromMilliseconds(1)
    $foregroundWindowTimer.Add_Tick({
        $parentWindow = [System.Windows.Window]::GetWindow($menu)

        $windowInteropHelper = New-Object System.Windows.Interop.WindowInteropHelper($parentWindow)
        $handle = $windowInteropHelper.Handle

        if ([Win32]::GetForegroundWindow() -ne $handle) {
            $global:counter--
            if ($global:counter -lt 0) {
                $global:counter = 0
            }

            $tutorialText.Text = "Tutorial will not progress until the window is focused"

            $foregroundWindowTimer.Stop()
        }
    })


    $animationTimer.Start()
}

Add-Type -TypeDefinition @'
    using System;
    using System.Runtime.InteropServices;

    public class Win32 {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
    }
'@