@echo off
setlocal
pushd "%~dp0\.."
where py >nul 2>nul
if not errorlevel 1 (
  py -3 Build\source_audit.py || goto :error
  py -3 Build\release_audit.py || goto :error
) else (
  python Build\source_audit.py || goto :error
  python Build\release_audit.py || goto :error
)
echo.
echo h5u.Grid static audits completed successfully.
popd
exit /b 0
:error
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
