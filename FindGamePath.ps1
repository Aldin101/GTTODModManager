function findGamePath {
    $steamPath = (Get-ItemProperty -path 'HKCU:\SOFTWARE\Valve\Steam').steamPath
    $lines = Get-Content "$steamPath\steamapps\libraryfolders.vdf"
    $newLines = New-Object -TypeName 'System.Collections.Generic.List[string]' -ArgumentList $lines.Count
    $newLines.Add("{") | Out-Null
    foreach ($line in $lines) {
        $matchCollection = [regex]::Matches($line, '\s*(\".*?\")')
        if ($matchCollection.Count -eq 2) {
            $line = $line.Replace($matchCollection[0].Groups[1].Value, ("{0}:" -f $matchCollection[0].Groups[1].Value))
            $secondVal = $matchCollection[1].Groups[1].Value.Clone()
            [int64]$tryLongVal = 0
            if ([int64]::TryParse($secondVal.Replace('"', ''), [ref] $tryLongVal)) {
                $secondVal = $secondVal.Replace('"', '')
            }
            $newLines.Add($line.Replace($matchCollection[1].Groups[1].Value, ("{0}," -f $secondVal))) | Out-Null
        } elseif ($matchCollection.Count -eq 1) {
            $newLines.Add($line.Replace($matchCollection[0].Groups[1].Value, ("{0}:" -f $matchCollection[0].Groups[1].Value))) | Out-Null
        } else {
            $newLines.Add($line) | Out-Null
        }
    }
    $newLines.Add("}") | Out-Null
    $joinedLine = $newLines -join "`n"
    $joinedLine = [regex]::Replace($joinedLine, '\}(\s*\n\s*\")', '},$1', "Multiline")
    $joinedLine = [regex]::Replace($joinedLine, '\"\,(\n\s*\})', '"$1', "Multiline")
    $joinedLine = $joinedLine -replace ',(\s*[\]}])', '$1'
    $libaryfolders = $joinedLine | ConvertFrom-Json

    foreach ($folder in $libaryfolders) {
        $gamePath = "$steamPath\steamapps\common\Get To The Orange Door\"
        if (Test-Path $gamePath) {
            return $gamePath.Replace("\", "/")
        }
    }
}