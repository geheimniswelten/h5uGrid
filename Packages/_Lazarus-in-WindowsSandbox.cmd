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
echo if not "%%username%%" == "WDAGUtilityAccount" @^( echo not in sandbox ^& pause ^& exit /b 1 ^)
echo.
echo set compdir=%%USERPROFILE%%\Desktop\%name%
echo set lazdir=%%USERPROFILE%%\Desktop\Lazarus
echo.
echo set "PATH=%%lazdir%%\fpc\3.2.2\bin\x86_64-win64;%%PATH%%"
echo.
echo if "%%1" == "--rebuild"   goto rebuild
echo   setx PATH "%%PATH%%" /M
echo   echo cmd /k "%%compdir%%%store%\lazarus_sandbox.cmd" --rebuild ^> "%%USERPROFILE%%\Desktop\rebuild-h5uGrid.cmd"
echo   "%%compdir%%%store%\%setup%" /SILENT /SUPPRESSMSGBOXES /NORESTART /DIR="%%lazdir%%" /LOG="%%lazdir%%-setup.log"
echo.
echo :rebuild
echo   taskkill /im lazarus.exe
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all "%%compdir%%\Packages\h5uGridCoreLazarus.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all "%%compdir%%\Packages\h5uGridLcl.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all --add-package "%%compdir%%\Packages\h5uGridCoreLazarusDesign.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all --add-package "%%compdir%%\Packages\h5uGridLclDesign.lpk"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all "%%compdir%%\Demos\LCL\ClientDataset\GridLclClientDatasetDemo.lpr"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all "%%compdir%%\Demos\LCL\ObjectList\GridLclObjectListDemo.lpr"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo "%%lazdir%%\lazbuild.exe" --build-all "%%compdir%%\Demos\LCL\VirtualLive\GridLclVirtualLiveDemo.lpr"
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo @echo ########################################################################
echo :: "%%lazdir%%\lazbuild.exe" --build-ide=""
echo :: "%%lazdir%%\lazbuild.exe" --build-ide=-dKeepInstalledPackages
echo :: cd "%%lazdir%%" & make all        Minimal-IDE
echo :: cd "%%lazdir%%" & make bigide     Base-IDE with Default-Packages ^(ignoriert Externes und Configs^)
echo :: cd "%%lazdir%%" & make useride    Final-IDE with Default- and Installed-Packages
echo ::
echo cd "%%lazdir%%"
echo make useride
echo if errorlevel 1   ^( echo ERROR %%errorlevel%% ^& pause ^)
echo.
echo cd "%%compdir%%"
echo REM start "" "%%compdir%%\Packages\h5uGridCoreLazarus.lpk"
echo REM start "" "%%compdir%%\Packages\h5uGridCoreLazarusDesign.lpk"
echo REM start "" "%%compdir%%\Packages\h5uGridLcl.lpk"
echo REM start "" "%%compdir%%\Packages\h5uGridLclDesign.lpk"
echo start "" "%%compdir%%\Demos\LCL\ObjectList\GridLclObjectListDemo.lpr"
echo.
echo REM start "" "%%compdir%%\GridProjectGroup.lpg"
echo REM start "" "%%lazdir%%\lazarus.exe" "%%compdir%%\GridProjectGroup.lpg"
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
