function Get-IniContent {
    param (
        [Parameter(Mandatory=$true)]
        [string] $FilePath
    )

    $ini = @{}
    switch -Regex -File $FilePath {
        "^\[(.+)\]$" {
            $section = $Matches[1]
            $ini[$section] = @{}
        }
        "^(.+)=(.*)" {
            if ($null -ne $section) {
                $name, $value = $Matches[1].Trim(), $Matches[2].Trim()
                $ini[$section][$name] = $value
            }
        }
    }
    return $ini
}

function Write-IniContent {
    param (
        [Parameter(Mandatory=$true)]
        [string] $FilePath,
        [Parameter(Mandatory=$true)]
        [hashtable] $Content
    )

    $ini = New-Object System.Text.StringBuilder
    foreach ($section in $Content.Keys) {
        $ini.AppendLine("[$section]")
        foreach ($key in $Content[$section].Keys) {
            $ini.AppendLine("$key=$($Content[$section][$key])")
        }
        $ini.AppendLine()
    }

    Set-Content -Path $FilePath -Value $ini.ToString()
}