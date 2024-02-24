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

    # Download the zip file
    $zipFile = Join-Path $env:TEMP "$modName.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

    # Extract the zip file to the game folder
    Expand-Archive -Path $zipFile -DestinationPath $gameFolder -Force

    # Delete the zip file
    Remove-Item $zipFile
}

function Uninstall-Mod {
    param (
        [Parameter(Mandatory)]
        [string[]] $files,
        [Parameter(Mandatory)]
        [string] $gameFolder
    )

    # Delete the files and directories
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