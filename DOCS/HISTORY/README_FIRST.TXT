NBJWLINK 0.0.5 - SELF-CONTAINED WINDOWS BUILD (OFFLINE)
=======================================================

This package includes the patched JWLINK 2.0 source and a project-local
Open Watcom v2 snapshot supplied by the user. YOU DO NOT NEED TO DOWNLOAD
OR INSTALL OPEN WATCOM, AND NO GLOBAL PATH CHANGES ARE MADE.

Install / overlay to C:\AI\JLINK (or another writable Windows directory).
Existing files in TOOLS\CACHE or TOOLS\OW_ROOT.TXT are obsolete, ignored.
Do not run the old downloader; MAKE.CMD has NO networking code.

BUILD / AUDIT (Windows 11 CMD or PowerShell)
  PRECHECK.CMD
  MAKE.CMD
  AUDIT.CMD
  MAKE_WIN1GUI.CMD

The compiled Windows host linker is BUILD\NBJWLINK.EXE.
MAKE.CMD compiles actual patched source with bundled WCC386.EXE, WLIB.EXE,
WMAKE.EXE and their support files. The pristine JWLINK v2 binary in
BOOTSTRAP is used as the HOST linker within the upstream make process.
Never confuse this with the target Win16 NE files: NBJWLINK.EXE is Win32 PE,
but OPTION WIN1 asks it to EMIT a Win16 NE executable.

NEW OPTION (in linker response/command line):
  FORMAT WINDOWS
  OPTION WIN1
  FILE app.obj
  NAME app.exe

WARNING / ACCEPTANCE
- Bundled compiler file set and PE32 architecture were inspected offline.
- Windows make, audit, and Win1 / Win3 /R runtime have NOT yet passed here.
- Do not give NBJWLINK to Qwen as a proven backend until Windows 1.01 UAT.
- No changes to original NBMINI or the original JWLINK binary.
- Real-mode startup code must be Win1-compatible in addition to linker layout.

THIRD-PARTY LICENSES
  TOOLS\OW_PORTABLE\license.txt  (Sybase Open Watcom Public License)
  BOOTSTRAP\License.txt       (JWLINK binary)
  SOURCE\jwlink-2.0\Ver\license.txt (JWLINK source)

TOOLS\OW_PORTABLE was extracted from user-provided ow-snapshot.tar.xz.
Included: binnt/, h/, lib386/, license.txt. Not included: unnecessary
DOS/Linux/OS2/ARM variants, docs, samples, installers.
