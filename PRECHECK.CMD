@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%~dp0"
if not defined WATCOM (
    echo FAIL: Set WATCOM to your existing Open Watcom root directory.
    echo Example: set "WATCOM=C:\WATCOM"
    exit /b 2
)
if not exist "%WATCOM%\binnt\wcc386.exe" (echo FAIL: Missing WCC386.EXE in "%WATCOM%\binnt" & exit /b 2)
for %%F in (WMAKE.EXE WLIB.EXE WLINK.EXE WCCD386.DLL WLINKD.DLL WLIBD.DLL WATCOM.DLL) do (
    if not exist "%WATCOM%\binnt\%%F" (echo FAIL: External Open Watcom file %%F missing & exit /b 2)
)
for %%F in (H\STDIO.H H\NT\WINDOWS.H LIB386\NT\KERNEL32.LIB LIB386\NT\USER32.LIB LIB386\NT\CLIB3R.LIB) do (
    if not exist "%WATCOM%\%%F" (echo FAIL: External Open Watcom file %%F missing & exit /b 2)
)
if not exist "%ROOT%BOOTSTRAP\JWlink.exe" (echo FAIL: JWlink bootstrap linker missing & exit /b 2)
if not exist "%ROOT%SOURCE\jwlink-2.0\Makefile" (echo FAIL: Patched JWlink source missing & exit /b 2)
if not exist "%ROOT%SOURCE\jwlink-2.0\c\loados2.c" (echo FAIL: Patched NE writer missing & exit /b 2)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\CHECK_TOOLCHAIN.PS1" -Watcom "%WATCOM%"
if errorlevel 1 (echo FAIL: toolchain architecture validation & exit /b 2)
echo PASS: existing Open Watcom x86 toolchain and NBJWLINK source found.
exit /b 0
