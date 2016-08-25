REM   Run an unsigned PowerShell script and log the output
PowerShell -ExecutionPolicy Unrestricted .\startup.ps1 "sha" "corp.contoso.com" >> "%TEMP%\StartupLog.txt" 2>&1
REM   If an error occurred, return the errorlevel.
EXIT /B %errorlevel%
