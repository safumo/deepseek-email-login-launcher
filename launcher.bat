@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

rem ============================================================
rem  DeepSeek overseas email-login launcher (Windows).
rem  Principle: point platform.deepseek.com at a CloudFront edge
rem  IP; with traffic routed through a non-CN exit, the sign-in
rem  page shows email / Google instead of +86 SMS.
rem  Usage: right-click -> Run as administrator.
rem  Revert: remove the platform.deepseek.com line from
rem    %SystemRoot%\System32\drivers\etc\hosts (Notepad as admin)
rem ============================================================

set "DOMAIN=platform.deepseek.com"
set "TARGET=https://platform.deepseek.com/sign_in"
set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"

rem --- 0. Elevate to administrator (required to edit hosts) ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Notice] Administrator rights are required to edit the hosts file. Requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

rem --- 1. Resolve the current CloudFront IP via overseas DNS ---
set "CFIP="
for /f "tokens=2 delims=:" %%a in ('nslookup %DOMAIN% 1.1.1.1 2^>nul ^| findstr /r /c:"Address.*[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"') do (
    set "CFIP=%%a"
)
if defined CFIP (
    for /f "tokens=* delims= " %%a in ("%CFIP%") do set "CFIP=%%a"
)
if not defined CFIP (
    echo [Notice] Overseas DNS resolution failed, falling back to a known IP.
    set "CFIP=3.173.21.63"
)
echo [Info] CloudFront IP: %CFIP%

rem --- 2. Rewrite hosts (drop stale entries first), flush DNS ---
findstr /v /c:"%DOMAIN%" "%HOSTS%" > "%HOSTS%.tmp" 2>nul
if not exist "%HOSTS%.tmp" type nul > "%HOSTS%.tmp"
echo %CFIP% %DOMAIN%>> "%HOSTS%.tmp"
move /y "%HOSTS%.tmp" "%HOSTS%" >nul
ipconfig /flushdns >nul
echo [Done] hosts updated: %CFIP% %DOMAIN%

rem --- 3. Detect installed browsers (info only), then open the
rem        sign-in page in the default browser to keep the user's
rem        saved sessions/passwords ---
set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe"        set "BROWSER=Chrome"
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"  set "BROWSER=Chrome"
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe"       set "BROWSER=Chrome"
if not defined BROWSER (
    if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=Edge"
    if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"      set "BROWSER=Edge"
)
if not defined BROWSER (
    if exist "%ProgramFiles%\Mozilla Firefox\firefox.exe"      set "BROWSER=Firefox"
    if exist "%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe" set "BROWSER=Firefox"
)
if defined BROWSER (echo [Info] Browser detected: %BROWSER%)

start "" "%TARGET%"

echo.
echo If the page shows the email / Google sign-in form, it worked.
echo If it still shows +86 SMS, your network has no overseas exit.
echo When done testing, open %HOSTS% in Notepad (as administrator)
echo and delete the line containing platform.deepseek.com.
pause
