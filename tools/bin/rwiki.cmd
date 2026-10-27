@echo off
rem rwiki: research-wiki command entry for PowerShell and cmd. Git Bash uses the sibling "rwiki".
rem RWIKI_HOME selects the skill copy to run; default is the .agents install.
setlocal
set "TEMP=E:\research-wiki-env\tmp"
set "TMP=E:\research-wiki-env\tmp"
set "MPLCONFIGDIR=E:\research-wiki-env\tmp\mpl"
if not defined RWIKI_HOME set "RWIKI_HOME=%USERPROFILE%\.agents\skills\research-wiki"
"C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe" -X utf8 "%RWIKI_HOME%\wiki.py" %*
exit /b %ERRORLEVEL%
