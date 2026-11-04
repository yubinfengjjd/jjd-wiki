@echo off
rem rwiki: research-wiki command entry for PowerShell and cmd. Git Bash uses the sibling "rwiki".
rem Shared bootstrap reads local config and discovers the dedicated Wiki interpreter.
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\machine-paths.ps1" %*
exit /b %ERRORLEVEL%
