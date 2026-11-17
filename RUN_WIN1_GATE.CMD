@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%~dp0"
call "%ROOT%MAKE.CMD"
if errorlevel 1 exit /b 1
call "%ROOT%AUDIT.CMD"
if errorlevel 1 exit /b 1
call "%ROOT%MAKE_WIN1GUI.CMD"
if errorlevel 1 exit /b 1
echo PASS: host build, structural audits, and Win1 GUI fixture build.
echo NEXT: test OUTPUT\WIN1GUI.EXE in Windows 1.01 and 3.0 /R; only guest PASS completes gate.
exit /b 0
