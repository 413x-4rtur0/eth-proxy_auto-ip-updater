@echo off
TITLE eth-proxy.bat
setlocal enabledelayedexpansion
set "adapter=Ethernet adapter Ethernet"
set ipv4= n/a 
set adapterfound=false
for /f "usebackq tokens=1-2 delims=:" %%f in (`ipconfig /all`) do (
    set "item=%%f"
    if /i "!item!"=="!adapter!" (
        set adapterfound=true
    ) else if not "!item!"=="!item:IPv4 Address=!" if "!adapterfound!"=="true" (
        set adapterfound=false
		set ipv4=%%g
	)
)
set ipv4=%IPv4:(Preferred)=%
set ipv4=%ipv4:~1,-1%
echo.%ipv4% >ip_log.txt
cd /d %~dp0 && cd..

@echo off
if not exist eth-proxy0.conf copy eth-proxy.conf eth-proxy0.conf
set file=eth-proxy0.conf
set insertline=33
set newline=HOST = "%ipv4%"
REM Use Set Output=Con to send to screen without amending code, or set it to a filename to make a new file
set output=eth-proxy.conf
(for /f "tokens=1* delims=[]" %%a in ('find /n /v "##" ^< "%file%"') do (
if "%%~a"=="%insertline%" (
echo %newline%
REM ECHO.%%b
) else (
echo.%%b
)
)) > %output%


start /wait /b eth-proxy.exe
wmic process where name="eth-proxy" CALL setpriority 256
wmic process where name="eth-proxy.exe" CALL setpriority 256
:: pause