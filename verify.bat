@echo off
setlocal
cd /d "%~dp0"
echo [1/2] building self-verification binary (contains #if SELF harness)...
dotnet build -c Release -p:DefineConstants=SELF -v q --nologo
if errorlevel 1 goto :err
echo [2/2] running parity suite against sign.js reference outputs...
dotnet bin\Release\net10.0\NTQQ-PureSignServer.dll selftest parity_reference.jsonl
if errorlevel 1 goto :err
echo.
echo All parity tests passed.
echo.
echo Next: run build.bat to produce a single-file, self-contained executable.
exit /b 0
:err
echo BUILD OR TEST FAILED
exit /b 1
