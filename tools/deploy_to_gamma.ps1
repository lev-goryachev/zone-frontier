param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourceGamedata = Join-Path $projectRoot "gamedata"
$gammaRoot = "D:\GAMMA"
$gammaMods = Join-Path $gammaRoot "mods"
$modName = "999- Zone Frontier"
$modRoot = Join-Path $gammaMods $modName
$targetGamedata = Join-Path $modRoot "gamedata"
$profileName = "G.A.M.M.A"
$profileRoot = Join-Path $gammaRoot "profiles\$profileName"
$modlistPath = Join-Path $profileRoot "modlist.txt"
$metaPath = Join-Path $modRoot "meta.ini"

function Write-Step {
    param([string]$Message)
    Write-Host "[deploy] $Message"
}

function Invoke-Step {
    param(
        [string]$Message,
        [scriptblock]$Action
    )

    if ($DryRun) {
        Write-Step "DRY RUN: $Message"
        return
    }

    Write-Step $Message
    & $Action
}

function Assert-Path {
    param(
        [string]$Path,
        [string]$Description
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing $Description`: $Path"
    }
}

function Assert-ChildPath {
    param(
        [string]$Child,
        [string]$Parent,
        [string]$Description
    )

    $resolvedChild = [System.IO.Path]::GetFullPath($Child)
    $resolvedParent = [System.IO.Path]::GetFullPath($Parent)

    if (-not $resolvedChild.StartsWith($resolvedParent, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Description is outside the allowed parent. Child: $resolvedChild Parent: $resolvedParent"
    }
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $base = [System.IO.Path]::GetFullPath($BasePath)
    $full = [System.IO.Path]::GetFullPath($FullPath)

    if (-not $base.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $base = $base + [System.IO.Path]::DirectorySeparatorChar
    }

    $baseUri = New-Object System.Uri($base)
    $fullUri = New-Object System.Uri($full)
    $relativeUri = $baseUri.MakeRelativeUri($fullUri)

    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace("/", "\")
}

Assert-Path $sourceGamedata "project gamedata directory"
Assert-Path (Join-Path $projectRoot "AGENTS.md") "project rules file"
Assert-Path $gammaMods "GAMMA mods directory"
Assert-Path $modlistPath "$profileName modlist"

Assert-ChildPath -Child $modRoot -Parent $gammaMods -Description "Zone Frontier mod target"
Assert-ChildPath -Child $targetGamedata -Parent $modRoot -Description "Zone Frontier gamedata target"

Write-Step "Project root: $projectRoot"
Write-Step "Source gamedata: $sourceGamedata"
Write-Step "Target mod: $modRoot"
Write-Step "Profile modlist: $modlistPath"

Invoke-Step "Create Zone Frontier MO2 mod directory" {
    New-Item -ItemType Directory -Force -Path $modRoot | Out-Null
}

if (Test-Path -LiteralPath $targetGamedata) {
    Invoke-Step "Remove previous Zone Frontier deployed gamedata" {
        Remove-Item -LiteralPath $targetGamedata -Recurse -Force
    }
}
else {
    Write-Step "No previous Zone Frontier deployed gamedata found"
}

Invoke-Step "Create fresh target gamedata directory" {
    New-Item -ItemType Directory -Force -Path $targetGamedata | Out-Null
}

$runtimeFiles = Get-ChildItem -LiteralPath $sourceGamedata -Recurse -File |
    Where-Object { $_.Name -ne ".gitkeep" }

foreach ($file in $runtimeFiles) {
    $relativePath = Get-RelativePath -BasePath $sourceGamedata -FullPath $file.FullName
    $destination = Join-Path $targetGamedata $relativePath
    $destinationDir = Split-Path -Parent $destination

    Invoke-Step "Copy gamedata\$relativePath" {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
    }
}

$metaContent = @"
[General]
gameName=stalkeranomaly
modid=0
version=0.1.0
newestVersion=0.1.0
category="-1,"
installationFile=
repository=Nexus
ignoredVersion=
comments=Zone Frontier local development deploy target.
notes=
nexusDescription=
url=https://github.com/lev-goryachev/zone-frontier
hasCustomURL=true
lastNexusQuery=
lastNexusUpdate=
nexusLastModified=1970-01-01T00:00:00Z
nexusCategory=0
converted=false
validated=false
color=@Variant(\0\0\0\x43\x1\xff\xff\0\0\0\0\0\0\0\0)
tracked=0
"@

Invoke-Step "Write MO2 meta.ini" {
    Set-Content -LiteralPath $metaPath -Value $metaContent -Encoding UTF8
}

$modEntry = "+$modName"
$disabledModEntry = "-$modName"
$modlistLines = Get-Content -LiteralPath $modlistPath

if ($modlistLines -contains $modEntry) {
    Write-Step "Modlist already contains $modEntry"
}
else {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$modlistPath.zf-backup-$timestamp"

    Invoke-Step "Backup $profileName modlist to $backupPath" {
        Copy-Item -LiteralPath $modlistPath -Destination $backupPath -Force
    }

    Invoke-Step "Enable $modEntry in $profileName modlist" {
        $lines = Get-Content -LiteralPath $modlistPath

        if ($lines -contains $disabledModEntry) {
            $updated = $lines | ForEach-Object {
                if ($_ -eq $disabledModEntry) {
                    $modEntry
                }
                else {
                    $_
                }
            }
        }
        elseif ($lines.Count -eq 0) {
            $updated = @($modEntry)
        }
        elseif ($lines[0] -like "#*") {
            $updated = @($lines[0], $modEntry) + $lines[1..($lines.Count - 1)]
        }
        else {
            $updated = @($modEntry) + $lines
        }

        Set-Content -LiteralPath $modlistPath -Value $updated -Encoding UTF8
    }
}

Write-Step "Deploy complete"
