# featureCounts Unofficial Windows Executable

This repository publishes a small Windows x64 package containing only
`featureCounts.exe`, extracted unmodified from the official Windows x86_64
Subread package.

This is an unofficial Windows redistribution. It is not published, endorsed,
or supported by the official Subread/featureCounts project.

Official featureCounts site: https://subread.sourceforge.net/featureCounts.html

## Included Version

- featureCounts: 2.1.1
- Source package: subread-2.1.1-Windows-x86_64.zip
- Corresponding source: `subread-2.1.1-source/` in this repository
- Target platform: Windows x64

## Installation

The recommended installation method is the MSI installer.

Download the MSI from the release page:

https://github.com/win-ngs/featurecounts-windows-exe/releases/tag/v2.1.1-windows-x86_64

Double-click the `.msi` file and follow the installer. The installer places
`featureCounts.exe` under `C:\Program Files\WinNGS-featureCounts` and adds that
directory to the system PATH.

<table>
  <tr>
    <td>
      <strong>Windows SmartScreen note</strong><br>
      If Windows shows a blue warning screen titled "Windows protected your PC",
      click the <strong>"More info"</strong> link, then click the
      <strong>"Run anyway"</strong> button to continue the installation.
    </td>
  </tr>
</table>

After installation, open a new PowerShell window and run:

```powershell
featureCounts -v
```

## ZIP Archive

If the MSI installer cannot be used, or if you prefer not to install the tool,
download the ZIP archive from the same release page:

https://github.com/win-ngs/featurecounts-windows-exe/releases/tag/v2.1.1-windows-x86_64

Extract it, open PowerShell in the extracted directory, and run:

```powershell
.\featureCounts.exe -v
```

The ZIP archive intentionally includes only `featureCounts.exe`. Other programs,
annotations, tests, documentation, and source files from the Subread package are
not included.

## License

featureCounts is part of the Subread package and is distributed under the GNU
General Public License version 3. See `LICENSE.md`.

The corresponding Subread 2.1.1 source is included in this repository under
`subread-2.1.1-source/`. See `THIRD_PARTY_NOTICES.md` for package provenance.
