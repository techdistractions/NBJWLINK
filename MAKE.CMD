@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%~dp0"
if not defined WATCOM (echo FAIL: Set WATCOM to an existing Open Watcom root, e.g. C:\WATCOM & exit /b 2)
set "OW_BIN=%WATCOM%\binnt"
set "WMAKE=%OW_BIN%\wmake.exe"
set "LOG=%ROOT%LOGS\BUILD_WIN32.LOG"
if not exist "%ROOT%LOGS" mkdir "%ROOT%LOGS"
if not exist "%ROOT%BUILD" mkdir "%ROOT%BUILD"
echo [0/3] Checking externally installed Open Watcom and source...
call "%ROOT%PRECHECK.CMD"
if errorlevel 1 exit /b 2
if exist "%ROOT%BUILD\NBJWLINK.EXE" del /q "%ROOT%BUILD\NBJWLINK.EXE"
if exist "%ROOT%BUILD\NBJWLINK.EXE" (echo FAIL: cannot remove stale EXE & exit /b 2)
rem The upstream makefile invokes JWlink.exe as its host bootstrap LINKER.
rem The unmodified bootstrap linker (not a compiler) is shipped in BOOTSTRAP.
set "INCLUDE=%WATCOM%\h;%WATCOM%\h\nt"
set "LIB=%WATCOM%\lib386\nt;%WATCOM%\lib386"
set "EDPATH=%WATCOM%\binnt"
set "PATH=%ROOT%BOOTSTRAP;%OW_BIN%;%PATH%"
echo [1/3] Verifying WMAKE sees external WATCOM root...
set "PROBE=%ROOT%LOGS\WATCOM_MACRO.LOG"
"%WMAKE%" -f "%ROOT%TESTS\WATCOM_PATH.MAK" "WATCOM=%WATCOM%" > "%PROBE%" 2>&1
if errorlevel 1 goto macro_fail
findstr.exe /L /C:"WATCOM_MACRO_RESOLVED=%WATCOM%" "%PROBE%" >nul 2>&1
if errorlevel 1 goto macro_fail
pushd "%ROOT%SOURCE\jwlink-2.0"
if errorlevel 1 (echo FAIL: source path & exit /b 2)
if not exist "Makefile" goto missing_source
if not exist "c\loados2.c" goto missing_source
findstr.exe /L /C:"WIN1 compatibility needs paragraph-aligned NE segments" "c\loados2.c" >nul 2>&1
if errorlevel 1 goto missing_source
rem Rebuild the changed NE writer, never reuse stale objects from ZIP snapshots.
if exist "build" (
    echo [clean] Removing stale upstream intermediate build directory...
    rmdir /s /q "build"
    if exist "build" goto clean_failed
)
echo [2/3] Building patched C source (external WCC386, WMAKE and WLIB)...
"%WMAKE%" -f Makefile DOS=0 "WATCOM=%WATCOM%" > "%LOG%" 2>&1
if errorlevel 1 goto failed
if not exist "build\jwlinkWR\JWlink.exe" goto failed
copy /y "build\jwlinkWR\JWlink.exe" "%ROOT%BUILD\NBJWLINK.EXE" >> "%LOG%" 2>&1
if errorlevel 1 goto failed
popd
if not exist "%ROOT%BUILD\NBJWLINK.EXE" goto failed_top
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%TESTS\CHECK_TOOLCHAIN.PS1" -Watcom "%WATCOM%" -BuiltLinker "%ROOT%BUILD\NBJWLINK.EXE" >> "%LOG%" 2>&1
if errorlevel 1 goto failed_top
echo [3/3] PASS: BUILT BUILD\NBJWLINK.EXE from patched source.
echo NEXT: AUDIT.CMD and optional MAKE_WIN1GUI.CMD; guest runtime testing still required.
exit /b 0
:missing_source
popd
echo FAIL: expected patched JWlink source marker missing.
exit /b 2
:clean_failed
popd
echo FAIL: could not remove stale source intermediate directory.
exit /b 2
:macro_fail
echo FAIL: external WATCOM root was not resolved by WMAKE. See "%PROBE%".
if exist "%PROBE%" type "%PROBE%"
exit /b 2
:failed
popd
:failed_top
echo FAIL: NBJWLINK build. See "%LOG%".
if exist "%LOG%" type "%LOG%"
exit /b 1
