# cleanBrowserCache.ps1
## This script was designed to clean browser cache files on a multi-user Windows server.

This is a Powershell script that deletes cache files for Microsoft Edge and Mozilla Firefox on a shared Windows server. It has been tested on Windows Server 2019.

In order to execute the script, in a Powershell prompt ran as an administrator, navigate to the directory containing the script and type the following:

```powershell
powershell.exe -executionpolicy bypass -file .\cleanBrowserCache.ps1
```
