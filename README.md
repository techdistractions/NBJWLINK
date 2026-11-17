# NBJWLINK

<img width="799" height="599" alt="nbjwlink" src="https://github.com/user-attachments/assets/17ac5cce-6bf7-404e-bb89-2d7118040249" />

**NBJWLINK 0.0.10** is a modified version of [JWlink 2.0](https://github.com/JWasm/JWlink) that adds an **opt-in Windows 1.x compatibility profile** for 16-bit Windows New Executable (NE) output.

The linker **runs on 32-bit-capable Windows** as a 32-bit x86 console application and **produces Win16 NE executables**. It is *not* itself a Windows 1.x application. The normal JWlink behaviour remains the default unless `OPTION WIN1` is specified.

## Download and use

Use the prebuilt **`BIN/NBJWLINK.EXE`** in this repository, or download the `NBJWLINK_0.0.10_Win32.zip` release asset. **Open Watcom is not needed to run NBJWLINK.**

Example linker response file (`app.rsp`):

```text
FORMAT WINDOWS
OPTION WIN1
FILE app.obj
NAME app.exe
```

Then run:

```cmd
NBJWLINK.EXE @app.rsp
```

`OPTION WIN1` selects the early-Windows-specific NE layout. It does not make otherwise incompatible startup code or API calls run under Windows 1.01. You must separately test the linked program under the intended Windows version.

## What changed

The patched source adds an early-Windows mode to the normal JWlink 2.0 linker:

- New `OPTION WIN1` directive, applicable to **Win16 NE** output only, with rejection for incompatible formats.
- Windows 1.x NE target metadata and segment flags.
- NE header at file offset `0x400`, with an explicit empty resource table.
- Minimum **16-byte NE segment alignment** in WIN1 mode.
- Correct full DOS MZ length fields for the generated output.
- Ordinary non-WIN1 Win16 output remains on the standard path.

See [`CHANGES.TXT`](CHANGES.TXT) and [`DOCS/PATCHES/`](DOCS/PATCHES/) for the chronological patch records. The full modified JWlink source is in [`SOURCE/jwlink-2.0/`](SOURCE/jwlink-2.0/).

## Building from source — external Open Watcom

**No compiler or assembler binaries are distributed with NBJWLINK.** To rebuild the 32-bit Windows linker, independently install an appropriate **Open Watcom v2 Windows x86 toolchain** with its headers/libraries and set the standard `WATCOM` environment variable to its installation root. A path without spaces is recommended by the inherited upstream makefile.

In Windows CMD:

```cmd
set "WATCOM=C:\WATCOM"
PRECHECK.CMD
MAKE.CMD
AUDIT.CMD
```

Replace `C:\WATCOM` with the path to **your** installed Open Watcom root. `MAKE.CMD` calls the installed `WMAKE.EXE`, `WCC386.EXE` and `WLIB.EXE`; it produces `BUILD/NBJWLINK.EXE`. A separate original upstream `BOOTSTRAP/JWlink.exe` **linker** is supplied to link the tool itself; this is *not a compiler*. No download, Open Watcom installation or system PATH modification is performed by the scripts.

For the optional 8086 GUI fixture build, independently provide JWASM:

```cmd
set "JWASM_EXE=C:\path\to\JWASM.EXE"
MAKE_WIN1GUI.CMD
```

Or add the JWASM directory to `PATH`. The full host-build + structural check + GUI fixture command is `RUN_WIN1_GATE.CMD`. Its success **does not** imply a Windows 1.01 runtime qualification.

`AUDIT.CMD` can validate either the supplied `BIN/NBJWLINK.EXE` or a freshly built `BUILD/NBJWLINK.EXE`, plus the included OMF fixture inputs. It checks WIN1 NE and default NE output and rejection of WIN1 for DOS/PE.

## Validation status

The original v0.0.9 Win32 binary came from the provided `JLINK.zip` (`BUILD/NBJWLINK.EXE`). The v0.0.10 release binary must be freshly rebuilt after the source-notice update. The accompanying **16 October 2026 Windows host logs** record a successful Open Watcom build, positive/negative NE structural checks, and a successful JWASM GUI fixture link. The binary has been retained byte-for-byte, with SHA-256 in [`RELEASE_NOTES.md`](RELEASE_NOTES.md).

**Updated 17 November 2026:** The maintainer subsequently reported a successful Windows-host rebuild with external Open Watcom (`PRECHECK`, `MAKE`) and a **5/5 structural `AUDIT` pass**. With independently installed JWASM, the `MAKE_WIN1GUI` fixture compiled and linked. A screenshot from **Windows 1.01 under DOSBox-X** shows `WIN1GUI.EXE` running and displaying the message `NBJWLINK WIN1: 8086 startup and OMF imports`. This is a confirmed **Win1 GUI smoke test**, not comprehensive Windows 1.x compatibility testing. **Windows 3.0 real-mode guest execution remains unverified.**

Prior to the v0.0.10 promotion step, `BIN/NBJWLINK.EXE` is still the archived v0.0.9 binary. After `PROMOTE_RELEASE.CMD` completes, it is the freshly rebuilt v0.0.10 binary, with its SHA-256 recorded in `dist/NBJWLINK_0.0.10_Win32/SHA256SUMS.txt`. Do not label or publish a v0.0.10 binary before building and promoting it. Contributors can rebuild with their own external toolchain; do not commit external Open Watcom or JWASM tools.

## Licensing and attribution

Based on the [JWlink project](https://github.com/JWasm/JWlink). The upstream source and bundled original JWlink bootstrap linker are provided under the **Sybase Open Watcom Public License v1.0**, with copyright notices preserved. See [`LICENSE.txt`](LICENSE.txt), [`SOURCE/jwlink-2.0/Ver/license.txt`](SOURCE/jwlink-2.0/Ver/license.txt) and [`BOOTSTRAP/License.txt`](BOOTSTRAP/License.txt). NBJWLINK changes are documented in [`CHANGES.TXT`](CHANGES.TXT).

Open Watcom itself and JWASM are **external build/test dependencies only** and are **not included**.

## Important license and source-code notice

NBJWLINK's modified JWlink source is publicly available at https://github.com/techdistractions/NBJWLINK.
Both the source and distributed executable contain the Sybase Open Watcom Public
License v1.0 source-availability notice. See [`NOTICE.txt`](NOTICE.txt) and
[`LICENSE.txt`](LICENSE.txt). Use of the covered code, including copying,
modification or distribution, constitutes acceptance of the licence. If you
do not accept its terms, do not use the covered code.

For v0.0.10, first run `MAKE`, `AUDIT`, and optionally `MAKE_WIN1GUI`
with external Open Watcom and JWASM. When host tests and any desired native
Windows 1.01 guest test have passed, run `PROMOTE_RELEASE.CMD` to copy the
new binary to `BIN/`, verify its embedded source URL, update the checksum
manifest and create the binary release ZIP. Do not distribute the old
`BIN/NBJWLINK.EXE` as v0.0.10 without promotion.
