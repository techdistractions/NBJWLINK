@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%~dp0"
set "BUILT=%ROOT%BUILD\NBJWLINK.EXE"
if not exist "%BUILT%" (echo FAIL: Build first with MAKE.CMD. & exit /b 2)
if not exist "%ROOT%LOGS\AUDIT_WIN1.LOG" (echo FAIL: Run AUDIT.CMD first. & exit /b 2)
rem Re-check the current freshly built binary before copying or packaging.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\CHECK_RELEASE_NOTICE.ps1" -Exe "%BUILT%"
if errorlevel 1 exit /b 2
copy /y "%BUILT%" "%ROOT%BIN\NBJWLINK.EXE" >nul
if errorlevel 1 (echo FAIL: Could not promote binary. & exit /b 2)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\UPDATE_MANIFEST.ps1"
if errorlevel 1 exit /b 2
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%PACKAGE_RELEASE.ps1" -Version "0.0.10"
if errorlevel 1 exit /b 2
echo PASS: BIN\NBJWLINK.EXE promoted, manifest updated, v0.0.10 release ZIP created.
echo NOTE: Check guest Windows 1.01 runtime and update release notes with results before publishing.
exit /b 0
