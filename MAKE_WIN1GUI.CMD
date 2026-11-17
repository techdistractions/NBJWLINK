@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%~dp0"
if not defined JWASM_EXE (
    where.exe JWASM.EXE >nul 2>&1
    if errorlevel 1 (
        echo FAIL: Set JWASM_EXE to your own JWASM.EXE, or add JWASM to PATH.
        exit /b 2
    )
    set "JWASM_EXE=JWASM.EXE"
)
set "LINKER=%ROOT%BUILD\NBJWLINK.EXE"
if not exist "%LINKER%" set "LINKER=%ROOT%BIN\NBJWLINK.EXE"
if not exist "%LINKER%" (echo FAIL: NBJWLINK.EXE missing. Run MAKE.CMD or use BIN\NBJWLINK.EXE. & exit /b 2)
if not exist "%ROOT%TESTS\RSP\WIN1GUI.RSP" (echo FAIL: GUI response file missing. & exit /b 2)
if not exist "%ROOT%TESTS\ASM\WIN1GUI.ASM" (echo FAIL: GUI assembler source missing. & exit /b 2)
if not exist "%ROOT%LOGS" mkdir "%ROOT%LOGS"
if not exist "%ROOT%OUTPUT" mkdir "%ROOT%OUTPUT"
set "LOG=%ROOT%LOGS\GUI_BUILD.LOG"
del /q "%ROOT%OUTPUT\WIN1GUI.OBJ" "%ROOT%OUTPUT\WIN1GUI.EXE" >nul 2>&1
"%JWASM_EXE%" -0 -omf -Fo"%ROOT%OUTPUT\WIN1GUI.OBJ" "%ROOT%TESTS\ASM\WIN1GUI.ASM" > "%LOG%" 2>&1
if errorlevel 1 goto fail
if not exist "%ROOT%OUTPUT\WIN1GUI.OBJ" goto fail
pushd "%ROOT%"
if errorlevel 1 goto fail
"%LINKER%" @TESTS\RSP\WIN1GUI.RSP >> "%LOG%" 2>&1
if errorlevel 1 (popd & goto fail)
popd
if not exist "%ROOT%OUTPUT\WIN1GUI.EXE" goto fail
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\AUDIT_NE.PS1" -OnlyGui >> "%LOG%" 2>&1
if errorlevel 1 goto fail
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\AUDIT_WIN1GUI.PS1" -Exe "%ROOT%OUTPUT\WIN1GUI.EXE" >> "%LOG%" 2>&1
if errorlevel 1 goto fail
echo PASS: WIN1GUI assembled and linked. Guest execution still required.
exit /b 0
:fail
echo FAIL: WIN1GUI build. See "%LOG%".
if exist "%LOG%" type "%LOG%"
exit /b 1
