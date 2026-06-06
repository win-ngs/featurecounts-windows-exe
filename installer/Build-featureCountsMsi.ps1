[CmdletBinding()]
param(
    # VersionLabel is the upstream-facing version string used in file names and
    # BUILDINFO.txt. ProductVersion must stay numeric for Windows Installer.
    [string] $VersionLabel = "2.1.1",
    [string] $ProductVersion = "2.1.1",

    # PackageFolderName points to the already assembled release folder under
    # dist/. This script does not build featureCounts.exe from source.
    [string] $PackageFolderName = "featureCounts-2.1.1-windows-x86_64",
    [string] $OutputName = "win-ngs-featureCounts-2.1.1-windows-x86_64.msi",

    # WinNGS installers are kept in English for global distribution instead of
    # following the user's Windows display language.
    [string] $Culture = "en-US",

    # WiX v7 requires an OSMF EULA acceptance. Keep this explicit so the script
    # never accepts terms as a hidden side effect.
    [switch] $AcceptWixEula
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Join-FullPath {
    param(
        [Parameter(Mandatory = $true)] [string] $Base,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $Base $Path))
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label not found: $Path"
    }
}

function Resolve-WixExe {
    # Prefer an explicit WIX_EXE when a maintainer wants to pin a specific WiX
    # install. Otherwise use PATH, then the default WiX Toolset v7 location.
    $envPath = [Environment]::GetEnvironmentVariable("WIX_EXE")
    if (-not [string]::IsNullOrWhiteSpace($envPath)) {
        Assert-PathExists -Path $envPath -Label "WIX_EXE"
        return [System.IO.Path]::GetFullPath($envPath)
    }

    $command = Get-Command "wix.exe" -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return [System.IO.Path]::GetFullPath($command.Source)
    }

    $defaultPath = "C:\Program Files\WiX Toolset v7.0\bin\wix.exe"
    if (Test-Path -LiteralPath $defaultPath -PathType Leaf) {
        return [System.IO.Path]::GetFullPath($defaultPath)
    }

    throw "Could not find wix.exe. Put it on PATH or set WIX_EXE."
}

function Copy-RequiredFile {
    param(
        [Parameter(Mandatory = $true)] [string] $Source,
        [Parameter(Mandatory = $true)] [string] $Destination
    )

    Assert-PathExists -Path $Source -Label "Required MSI input"
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

# Resolve paths relative to this repository so the script can be run from the
# repository root without hard-coded user-specific directories.
$installerDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $installerDir
$distDir = Join-FullPath -Base $repoRoot -Path "dist"
$packageDir = Join-FullPath -Base $distDir -Path $PackageFolderName
$msiRoot = Join-FullPath -Base $distDir -Path "msi-root"
$toolRoot = Join-FullPath -Base $msiRoot -Path "WinNGS-featureCounts"
$wxsPath = Join-FullPath -Base $installerDir -Path "featurecounts.wxs"
$licenseRtfPath = Join-FullPath -Base $installerDir -Path "LICENSE.rtf"
$outputMsi = Join-FullPath -Base $distDir -Path $OutputName

Assert-PathExists -Path $packageDir -Label "featureCounts release package folder"
Assert-PathExists -Path $wxsPath -Label "WiX source"
Assert-PathExists -Path $licenseRtfPath -Label "WiX UI license RTF"

# Recreate only dist/msi-root. The safety check prevents accidental recursive
# deletion outside dist/ if a path variable is changed incorrectly later.
if (Test-Path -LiteralPath $msiRoot) {
    $distFull = [System.IO.Path]::GetFullPath($distDir).TrimEnd('\') + '\'
    $msiRootFull = [System.IO.Path]::GetFullPath($msiRoot)
    if (-not $msiRootFull.StartsWith($distFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to delete unsafe MSI staging directory: $msiRootFull"
    }
    Remove-Item -LiteralPath $msiRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $toolRoot | Out-Null

# The release executable is copied without strip so it remains byte-identical to
# the official Subread Windows package described in THIRD_PARTY_NOTICES.md.
Copy-RequiredFile -Source (Join-Path $packageDir "featureCounts.exe") -Destination $toolRoot
Copy-RequiredFile -Source (Join-Path $repoRoot "LICENSE.md") -Destination $toolRoot
Copy-RequiredFile -Source (Join-Path $repoRoot "THIRD_PARTY_NOTICES.md") -Destination $toolRoot

# README.md is intentionally not installed; GitHub README is the user-facing
# document and should not force rebuilding release assets when only docs change.
# BUILDINFO.txt gives installed users minimal provenance without duplicating
# the repository README in the MSI payload.
$buildInfo = @(
    "WinNGS featureCounts MSI"
    "========================"
    ""
    "featureCounts: $VersionLabel"
    "Source package: subread-2.1.1-Windows-x86_64.zip"
    "Install directory: C:\Program Files\WinNGS-featureCounts"
    ""
    "Installed files:"
    "- featureCounts.exe"
    "- LICENSE.md"
    "- THIRD_PARTY_NOTICES.md"
)
Set-Content -LiteralPath (Join-Path $toolRoot "BUILDINFO.txt") -Value $buildInfo -Encoding ASCII

# The .wxs file is hand-maintained WiX authoring. This script supplies version,
# staging-root, and license-page paths as build-time variables.
$wixExe = Resolve-WixExe
if ($AcceptWixEula) {
    & $wixExe eula accept wix7
    if ($LASTEXITCODE -ne 0) {
        throw "wix eula accept failed with exit code $LASTEXITCODE"
    }
}

$wixArgs = @(
    "build",
    $wxsPath,
    "-arch", "x64",
    "-culture", $Culture,
    "-ext", "WixToolset.UI.wixext",
    "-d", "ProductVersion=$ProductVersion",
    "-d", "VersionLabel=$VersionLabel",
    "-d", "MsiRoot=$msiRoot",
    "-d", "InstallerLicenseRtf=$licenseRtfPath",
    "-o", $outputMsi
)

# WiX embeds the cabinet into the MSI, so the resulting .msi is the only file
# that needs to be uploaded as the installer release asset.
& $wixExe @wixArgs
if ($LASTEXITCODE -ne 0) {
    throw "wix build failed with exit code $LASTEXITCODE"
}

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $outputMsi
Write-Host ("Wrote {0}" -f $outputMsi)
Write-Host ("SHA256 {0}  {1}" -f $hash.Hash, (Split-Path -Leaf $outputMsi))
