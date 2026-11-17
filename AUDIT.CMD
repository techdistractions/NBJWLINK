@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%~dp0"
set "LINKER=%ROOT%BUILD\NBJWLINK.EXE"
if not exist "%LINKER%" set "LINKER=%ROOT%BIN\NBJWLINK.EXE"
set "LOG=%ROOT%LOGS\AUDIT_WIN1.LOG"
if not exist "%LINKER%" (echo FAIL: NBJWLINK.EXE missing in BUILD or BIN. & exit /b 2)
if not exist "%ROOT%TESTS\AUDIT_NE.PS1" (echo FAIL: TESTS\AUDIT_NE.PS1 missing. & exit /b 2)
if not exist "%ROOT%LOGS" mkdir "%ROOT%LOGS"
if not exist "%ROOT%OUTPUT" mkdir "%ROOT%OUTPUT"
rem All linker directives must be separate lines in a RESPONSE file.
rem One quoted argument with all directives is NOT understood by JWLINK.
for %%R in (WIN1MIN WIN1MULTI STDNE BLOCKDOS BLOCKPE) do (
    if not exist "%ROOT%TESTS\RSP\%%R.RSP" (echo FAIL: TESTS\RSP\%%R.RSP missing. & exit /b 2)
)
rem Remove stale outputs before positive/negative assertions.
del /q "%ROOT%OUTPUT\WIN1MIN.EXE" "%ROOT%OUTPUT\WIN1MULTI.EXE" "%ROOT%OUTPUT\STDNE.EXE" "%ROOT%OUTPUT\BLOCKDOS.EXE" "%ROOT%OUTPUT\BLOCKPE.EXE" >nul 2>&1
pushd "%ROOT%"
if errorlevel 1 (echo FAIL: cannot change into project directory. & exit /b 2)
echo NBJWLINK 0.0.9 native Win16 NE audit (RSP command syntax) > "%LOG%"
echo [1/5] Win1 profile OMF...
"%LINKER%" @TESTS\RSP\WIN1MIN.RSP >> "%LOG%" 2>&1
if errorlevel 1 goto fail
if not exist "OUTPUT\WIN1MIN.EXE" goto fail
echo [2/5] Multi-object OMF cross-OBJ FIXUPP...
"%LINKER%" @TESTS\RSP\WIN1MULTI.RSP >> "%LOG%" 2>&1
if errorlevel 1 goto fail
if not exist "OUTPUT\WIN1MULTI.EXE" goto fail
echo [3/5] Default Win16 NE remains unchanged...
"%LINKER%" @TESTS\RSP\STDNE.RSP >> "%LOG%" 2>&1
if errorlevel 1 goto fail
if not exist "OUTPUT\STDNE.EXE" goto fail
echo [4/5] DOS rejects WIN1...
"%LINKER%" @TESTS\RSP\BLOCKDOS.RSP >> "%LOG%" 2>&1
if not errorlevel 1 goto fail
if exist "OUTPUT\BLOCKDOS.EXE" goto fail
echo [5/5] PE rejects WIN1...
"%LINKER%" @TESTS\RSP\BLOCKPE.RSP >> "%LOG%" 2>&1
if not errorlevel 1 goto fail
if exist "OUTPUT\BLOCKPE.EXE" goto fail
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\AUDIT_NE.PS1" >> "%LOG%" 2>&1
if errorlevel 1 goto fail
popd
echo PASS: structural OMF/Win1 regression. Runtime test still required.
exit /b 0
:fail
popd
echo FAIL: linker or structural gate. See "%LOG%".
if exist "%LOG%" type "%LOG%"
exit /b 1
