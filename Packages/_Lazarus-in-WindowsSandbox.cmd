chcp 65001 >nul

:: https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2064%20bits/Lazarus%204.8/
set download=https://sourceforge.net/projects/lazarus/files/Lazarus%%20Windows%%2064%%20bits/Lazarus%%204.8/lazarus-4.8-fpc-3.2.2-win64.exe/download
set setup=lazarus-4.8-fpc-3.2.2-win64.exe

cd /d "%~dp0.."
set root=%cd%
set name=h5u.Grid
set store=\_dcu

::del "%root%%store%\%setup%"
md "%root%%store%" 2>NUL
robocopy "%root%%store%" "%temp%" "*.exe" /MOV /MAX:1048576
if not exist "%root%%store%\%setup%"   curl.exe -L -o "%root%%store%\%setup%" %download%

(
echo TITLE Install and Start Lazarus + h5uGrid
echo.
echo if "%%1" == "--rebuild"   goto rebuild
echo   "%%USERPROFILE%%\Desktop\%name%%store%\%setup%" /SILENT /SUPPRESSMSGBOXES /NORESTART /DIR="%%USERPROFILE%%\Desktop\Lazarus" /LOG="%%USERPROFILE%%\Desktop\lazarus-setup.log"
echo   echo cmd /k "%%USERPROFILE%%\Desktop\%name%%store%\lazarus_sandbox.cmd" --rebuild ^> "%%USERPROFILE%%\Desktop\rebuild-h5uGrid.cmd"
echo.
echo :rebuild
echo   taskkill /im lazarus.exe
echo.
echo set "PATH=%%USERPROFILE%%\Desktop\Lazarus\fpc\3.2.2\bin\x86_64-win64;%%PATH%%"
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridCoreLazarus.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridLcl.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all --add-package "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridCoreLazarusDesign.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all --add-package "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridLclDesign.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all "%%USERPROFILE%%\Desktop\%name%\Demos\LCL\ClientDataset\GridLclClientDatasetDemo.lpr"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all "%%USERPROFILE%%\Desktop\%name%\Demos\LCL\ObjectList\GridLclObjectListDemo.lpr"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-all "%%USERPROFILE%%\Desktop\%name%\Demos\LCL\VirtualLive\GridLclVirtualLiveDemo.lpr"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%USERPROFILE%%\Desktop\Lazarus\lazbuild.exe" --build-ide=""
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridCoreLazarus.lpk"
echo start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridCoreLazarusDesign.lpk"
echo REM start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridLcl.lpk"
echo REM start "" "%%USERPROFILE%%\Desktop\%name%\Packages\h5uGridLclDesign.lpk"
echo.
echo REM start "" "%%USERPROFILE%%\Desktop\%name%\GridProjectGroup.lpg"
echo REM start "" "%%USERPROFILE%%\Desktop\Lazarus\lazarus.exe" "%%USERPROFILE%%\Desktop\%name%\GridProjectGroup.lpg"
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
echo     ^<Command^>cmd /c start "" cmd /c cmd /k "%%USERPROFILE%%\Desktop\%name%%store%\lazarus_sandbox.cmd"^</Command^>
echo   ^</LogonCommand^>
echo ^</Configuration^>
) > "%root%%store%\lazarus_sandbox.wsb"

"%root%%store%\lazarus_sandbox.wsb"
