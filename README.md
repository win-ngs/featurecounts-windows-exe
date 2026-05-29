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

## Usage

Download the release ZIP from:

https://github.com/win-ngs/featurecounts-windows-exe/releases/tag/v2.1.1-windows-x86_64

Extract it, and run:

```powershell
.\featureCounts.exe -v
```

This archive intentionally includes only `featureCounts.exe`. Other programs,
annotations, tests, documentation, and source files from the Subread package are
not included in this release archive.

## License

featureCounts is part of the Subread package and is distributed under the GNU
General Public License version 3. See `LICENSE.md`.

The corresponding Subread 2.1.1 source is included in this repository under
`subread-2.1.1-source/`. See `THIRD_PARTY_NOTICES.md` for package provenance.
