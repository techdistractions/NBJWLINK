# NBJWLINK 0.0.10 - Source / licence notice update

Release date: 2026-11-17. Previous version: v0.0.9.

This release improves notice compliance for the Sybase Open Watcom Public
License v1.0. It does **not** change the Windows 1.x NE format implementation.

## Changes

- Dated modification notices in five upstream C/header files, the modified
  upstream Makefile, and the linker banner header changed in this release.
- The Win32 linker banner reports where the covered source is available:
  https://github.com/techdistractions/NBJWLINK
- The binary package contains the complete LICENSE.txt, NOTICE.txt,
  README.txt, these release notes, and SHA256SUMS.txt.
- Includes no Open Watcom compiler or JWASM assembler binary.

## Build and testing

- The v0.0.9 build and five structural audit checks passed on 2026-11-17.
- A Win1.01 GUI fixture executed successfully in DOSBox-X for v0.0.9.
- **v0.0.10 build and audit: NOT VERIFIED until performed by the maintainer.**
- **v0.0.10 Windows 1.01 runtime smoke test: NOT VERIFIED until repeated.**
- Windows 3.0 real-mode guest execution: NOT VERIFIED.

The `PROMOTE_RELEASE.CMD` script validates that the rebuilt linker contains the
source URL and prepares the v0.0.10 binary package. The current binary hash is
recorded in `SHA256SUMS.txt` inside the package after promotion.

## Source and licence

Upstream JWlink 2.0: https://github.com/JWasm/JWlink
Modified NBJWLINK source: https://github.com/techdistractions/NBJWLINK

Covered source and executable are made available under the Sybase Open Watcom
Public License v1.0. See LICENSE.txt and NOTICE.txt. Any use (including
copying, modification or distribution) constitutes acceptance of the licence;
users who do not accept the terms must not use the covered code.

The underlying licence and notices remain unaltered. The upstream JWlink
bootstrap linker included in the source repository retains its own notices.
