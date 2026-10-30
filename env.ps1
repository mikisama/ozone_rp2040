function Add-EnvPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathToAdd,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Prepend", "Append")]
        [string]$Position = "Prepend"
    )

    # 1. Normalize the target path (handle '/' vs '\', casing, and trailing slashes)
    try {
        $normalizedTarget = [System.IO.Path]::GetFullPath($PathToAdd).TrimEnd('\', '/')
    } catch {
        Write-Error "Invalid path format: $PathToAdd"
        return
    }

    # 2. Split current PATH and check for duplicates against normalized paths
    $pathArray = $env:Path -split ';' | Where-Object { $_ -ne '' }
    $exists = $false

    foreach ($p in $pathArray) {
        try {
            $normalizedCurrent = [System.IO.Path]::GetFullPath($p).TrimEnd('\', '/')
            if ($normalizedCurrent -eq $normalizedTarget) {
                $exists = $true
                break
            }
        } catch {
            # Skip invalid/malformed paths that may exist in system PATH
            continue
        }
    }

    # 3. Inject path if not already present
    if (-not $exists) {
        if ($Position -eq "Prepend") {
            $env:Path = "$PathToAdd;$env:Path"
        } else {
            $env:Path = "$env:Path;$PathToAdd"
        }
        Write-Host "Successfully added to PATH: $PathToAdd" -ForegroundColor Green
    } else {
        Write-Host "Path already exists, skipping: $PathToAdd" -ForegroundColor Yellow
    }
}

Add-EnvPath "$env:USERPROFILE/.pico-sdk/toolchain/14_2_Rel1/bin"
