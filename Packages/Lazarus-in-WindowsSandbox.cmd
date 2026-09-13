chcp 65001 >nul

:: https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2064%20bits/Lazarus%204.8/
set download=https://sourceforge.net/projects/lazarus/files/Lazarus%%20Windows%%2064%%20bits/Lazarus%%204.8/lazarus-4.8-fpc-3.2.2-win64.exe/download
set setup=lazarus-4.8-fpc-3.2.2-win64.exe

cd /d "%~dp0.."
set root=%cd%
set name=h5u.Grid
set store=\_dcu

::del "%root%%store%\%setup%"
robocopy "%root%%store%" "%temp%" "*.exe" /MOV /MAX:1048576
if not exist "%root%%store%\%setup%"   curl.exe -L -o "%root%%store%\%setup%" %download%

(
echo TITLE Install and Start Lazarus
echo.
echo "%%USERPROFILE%%\Desktop\%name%%store%\%setup%" /SILENT /SUPPRESSMSGBOXES /NORESTART /DIR="%%USERPROFILE%%\Desktop\Lazarus" /LOG="%%USERPROFILE%%\Desktop\lazarus-setup.log"
echo.
echo start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridCoreLazarus.lpk"
echo start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridCoreLazarusDesign.lpk"
echo REM start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridLcl.lpk"
echo REM start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridLclDesign.lpk"
echo.
echo REM start "" "%%USERPROFILE%%\Desktop\%name%\GridProjectGroup.lpg"
echo REM start "" "%%USERPROFILE%%\Desktop\Lazarus\Lazarus.exe" "%%USERPROFILE%%\Desktop\%name%\GridProjectGroup.lpg"
) > "%root%%store%\lazarus_sandbox.cmd"

(
echo ^<Configuration^>
echo   ^<MappedFolders^>
echo     ^<MappedFolder^>
echo       ^<HostFolder^>%root%^</HostFolder^>
echo       ^<SandboxFolder^>%%USERPROFILE%%\Desktop\%name%^</SandboxFolder^>
echo       ^<ReadOnly^>false^</ReadOnly^>
echo     ^</MappedFolder^>
echo   ^</MappedFolders^>
echo   ^<LogonCommand^>
echo     ^<Command^>cmd /c start "" cmd /c cmd /c "%%USERPROFILE%%\Desktop\%name%%store%\lazarus_sandbox.cmd"^</Command^>
echo   ^</LogonCommand^>
echo ^</Configuration^>
) > "%root%%store%\lazarus_sandbox.wsb"

"%root%%store%\lazarus_sandbox.wsb"
