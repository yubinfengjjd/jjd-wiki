' Double-click entry: runs launcher.ps1 next to this file with no console window.
' launcher.ps1 starts the server, opens an app window, and stops the server when it closes.
Set fso = CreateObject("Scripting.FileSystemObject")
script = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), "launcher.ps1")
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -WindowStyle Hidden -File """ & script & """", 0, False
