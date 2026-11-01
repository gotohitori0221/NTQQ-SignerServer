@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

where dotnet >nul 2>&1
if errorlevel 1 (
    echo [ERR] dotnet CLI not found. Install the .NET SDK from https://dotnet.microsoft.com/download
    exit /b 1
)

echo Installed SDKs:
dotnet --list-sdks
echo.

set "TFM="
call :probe net10.0
call :probe net9.0
call :probe net8.0

if "%TFM%"=="" (
    echo [ERR] No usable target framework. Install the .NET 10, 9 or 8 SDK.
    exit /b 1
)

echo [1/3] Building Release binaries...
dotnet build -c Release -p:TargetFramework=%TFM% -v q --nologo
if errorlevel 1 (
    echo [ERR] Build failed.
    exit /b 1
)

where obfuscar.console >nul 2>&1
if not errorlevel 1 (
    if exist "obfuscar.xml" (
        echo [2/3] Applying Obfuscar symbol and control-flow obfuscation...
        obfuscar.console obfuscar.xml
        if exist "bin\Release\%TFM%\obfuscated\NTQQ-PureSignServer.dll" (
            copy /y "bin\Release\%TFM%\obfuscated\NTQQ-PureSignServer.dll" "bin\Release\%TFM%\NTQQ-PureSignServer.dll" >nul
            echo [OK] Obfuscated assembly injected.
        )
    )
) else (
    echo [2/3] obfuscar.console not found in PATH, skipping IL obfuscation step.
)

echo [3/3] Packaging single-file self-contained binaries...
echo  - Publishing win-x64...
dotnet publish -c Release -r win-x64 --self-contained true -p:TargetFramework=%TFM% /p:PublishSingleFile=true /p:EnableCompressionInSingleFile=true /p:DebugType=none /p:DebugSymbols=false -v q --nologo
if errorlevel 1 (
    echo [ERR] win-x64 publish failed.
    exit /b 1
)

echo  - Publishing linux-x64...
dotnet publish -c Release -r linux-x64 --self-contained true -p:TargetFramework=%TFM% /p:PublishSingleFile=true /p:EnableCompressionInSingleFile=true /p:DebugType=none /p:DebugSymbols=false -v q --nologo
if errorlevel 1 (
    echo [ERR] linux-x64 publish failed.
    exit /b 1
)

echo.
echo Build OK for both platforms!
echo Windows output: bin\Release\%TFM%\win-x64\publish\NTQQ-PureSignServer.exe
echo Linux   output: bin\Release\%TFM%\linux-x64\publish\NTQQ-PureSignServer
echo.
exit /b 0

:probe
if "%TFM%"=="" (
    echo [probe] trying %1 ...
    dotnet build -c Release -p:TargetFramework=%1 -v q --nologo >nul 2>&1
    if errorlevel 1 (
        echo [probe] %1 not usable, skipping
        exit /b 1
    )
    set "TFM=%1"
    echo [probe] %1 selected
)
exit /b 0
