# Add these functions at the top of your script
function Install-Mod {
    param (
        [Parameter(Mandatory)]
        [string] $modName,
        [Parameter(Mandatory)]
        [string] $downloadUrl,
        [Parameter(Mandatory)]
        [string] $gameFolder
    )

    if (!(Test-Path $gameFolder)) {
        return
    }

    $zipFile = Join-Path $env:TEMP "$modName.zip"
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to download mod $modName.`n`n$_", "GTTOD Mod Manager", "OK", "Error")
    }

    Expand-Archive -Path $zipFile -DestinationPath $gameFolder -Force

    Remove-Item $zipFile
}

function Uninstall-Mod {
    param (
        [Parameter(Mandatory)]
        [string[]] $files,
        [Parameter(Mandatory)]
        [string] $gameFolder
    )

    if (!(Test-Path "$gameFolder$($files[0])")) {
        return
    }

    if (!(Test-Path $gameFolder)) {
        return
    }

    foreach ($file in $files) {
        $path = Join-Path $gameFolder $file
        if (Test-Path $path) {
            if ((Get-Item $path) -is [System.IO.DirectoryInfo]) {
                Remove-Item $path -Recurse
            } else {
                Remove-Item $path
            }
        }
    }
}