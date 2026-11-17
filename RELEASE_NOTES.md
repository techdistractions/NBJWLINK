# NBJWLINK 0.0.9 — release notes

Source history date: **16 October 2026**. Packaged for GitHub: **17 November 2026**.

This release packages the source and previously compiled Windows x86 linker from the user-supplied `JLINK.zip`, with packaging-only adjustments to build against an **externally installed Open Watcom** compiler instead of a project-local compiler directory. **No Open Watcom compiler or JWASM assembler is included.**

## Functional changes

- `OPTION WIN1` to select early-Windows NE output.
- Win1-specific segment metadata, minimum 16-byte alignment, 0x400 NE header positioning, empty resource table and complete MZ file sizing.
- Preserved ordinary/default JWlink output semantics without WIN1 mode.
- Win1-positive and non-Win1-negative OMF/NE regression fixtures.

## Prebuilt executable

- `BIN/NBJWLINK.EXE`: **306,688 bytes**, Windows x86 PE32.
- SHA-256: `dcac1c2fec4b4897be6d52d9b5b70a07530e9f68677d3d03589c6ff8c09cfa27`

## Qualification

- **Historical source archive:** Source, binary headers, fixtures, and archived binary SHA-256 checked during packaging.
- **17 November 2026 Windows host rebuild:** Maintainer ran `PRECHECK` and `MAKE` with an external Open Watcom installation; both passed and generated `BUILD\NBJWLINK.EXE`.
- **17 November 2026 structural regression:** `AUDIT` passed **5/5** checks (WIN1 OMF, multi-object FIXUPP, ordinary Win16 NE, and WIN1 rejection for DOS and PE output).
- **17 November 2026 Windows 1.01 GUI smoke test:** The optional JWASM `WIN1GUI.EXE` fixture compiled and linked, then visibly executed under Windows 1.01 in DOSBox-X. The screenshot shows the expected `NBJWLINK WIN1: 8086 startup and OMF imports` dialog. This confirms that one test program runs; it does **not** qualify the entire linker or API surface.
- **Windows 3.0 /R runtime:** NOT VERIFIED.
- **Binary provenance:** The packaged `BIN/NBJWLINK.EXE` retains the original archive bytes and hash above; the newly rebuilt `BUILD/NBJWLINK.EXE` was not supplied for byte-comparison or replacement.

## Upstream and licensing

Modified JWlink 2.0. See `LICENSE.txt`, `CHANGES.TXT`, `SOURCE/jwlink-2.0/Ver/license.txt` and `BOOTSTRAP/License.txt`. The original `BOOTSTRAP/JWlink.exe` is included as an upstream **linker**, not a compiler. No compiler distribution is included.
