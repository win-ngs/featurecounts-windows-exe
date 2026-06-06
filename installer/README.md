# featureCounts MSI installer

This directory contains WiX authoring for the featureCounts MSI installer.
It uses the WiX standard minimal UI with fixed `en-US` localization and shows
`Installation completed successfully.` on the final dialog after a successful
first-time install.

The MSI installs files under:

```text
C:\Program Files\WinNGS-featureCounts\
  featureCounts.exe
  BUILDINFO.txt
  LICENSE.md
  THIRD_PARTY_NOTICES.md
```

`C:\Program Files\WinNGS-featureCounts` is added to the system PATH by the MSI.
The installer owns only the featureCounts install directory and its own PATH
entry, so uninstalling featureCounts does not affect other WinNGS tools.

The executable is not stripped. It remains byte-identical to the official
Subread Windows package described in `THIRD_PARTY_NOTICES.md`.

Build the MSI:

```powershell
wix extension add -g WixToolset.UI.wixext/7.0.0
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\Build-featureCountsMsi.ps1
```

WiX Toolset v7 requires accepting the WiX OSMF EULA before building. If it has
not already been accepted:

```powershell
wix eula accept wix7
```

or run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\Build-featureCountsMsi.ps1 -AcceptWixEula
```

The output is:

```text
dist\win-ngs-featureCounts-2.1.1-windows-x86_64.msi
```

Validate the MSI without installing:

```powershell
wix msi validate .\dist\win-ngs-featureCounts-2.1.1-windows-x86_64.msi
```

Record the MSI SHA256 and ProductCode before updating winget manifests:

```powershell
Get-FileHash -Algorithm SHA256 .\dist\win-ngs-featureCounts-2.1.1-windows-x86_64.msi
$out = "C:\tmp\win-ngs-featureCounts-msi.wxs"
wix msi decompile .\dist\win-ngs-featureCounts-2.1.1-windows-x86_64.msi -o $out
rg -n "ProductCode|UpgradeCode|Environment|WinNGS-featureCounts" $out
```
