@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

rem ============================================================
rem  DeepSeek 海外邮箱登录启动器（Windows 版）
rem  原理：把 platform.deepseek.com 指向 CloudFront 海外节点，
rem        网络把海外流量送到非中国大陆出口后，登录页显示邮箱/Google 登录
rem  用法：右键 -> 以管理员身份运行
rem  还原：以管理员身份执行
rem    findstr /v "platform.deepseek.com" %SystemRoot%\System32\drivers\etc\hosts ^> %SystemRoot%\System32\drivers\etc\hosts.new
rem    （再手动删除 hosts.new 或用记事本编辑 hosts 移除对应行）
rem ============================================================

set "DOMAIN=platform.deepseek.com"
set "TARGET=https://platform.deepseek.com/sign_in"
set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"

rem ---------- 0. 检查并请求管理员权限（修改 hosts 需要） ----------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 需要管理员权限才能修改 hosts 文件，正在请求提升...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

rem ---------- 1. 解析 CloudFront 当前 IP（走海外 DNS 1.1.1.1） ----------
set "CFIP="
for /f "tokens=2 delims=:" %%a in ('nslookup %DOMAIN% 1.1.1.1 2^>nul ^| findstr /r /c:"Address.*[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"') do (
    set "CFIP=%%a"
)
rem 去掉首尾空格；解析失败则用已知可用 IP 兜底
if defined CFIP (
    for /f "tokens=* delims= " %%a in ("%CFIP%") do set "CFIP=%%a"
)
if not defined CFIP (
    echo [提示] 海外 DNS 解析失败，使用兜底 IP。
    set "CFIP=3.173.21.63"
)
echo [信息] CloudFront IP: %CFIP%

rem ---------- 2. 写入 hosts（先移除旧条目，避免重复） ----------
findstr /v /c:"%DOMAIN%" "%HOSTS%" > "%HOSTS%.tmp" 2>nul
if not exist "%HOSTS%.tmp" type nul > "%HOSTS%.tmp"
echo %CFIP% %DOMAIN%>> "%HOSTS%.tmp"
move /y "%HOSTS%.tmp" "%HOSTS%" >nul
ipconfig /flushdns >nul
echo [完成] hosts 已写入：%CFIP% %DOMAIN%

rem ---------- 3. 检测已安装的浏览器并打开登录页 ----------
set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe"        set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"  set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe"       set "BROWSER=%LocalAppData%\Google\Chrome\Application\chrome.exe"

if not defined BROWSER (
    if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
    if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"      set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
)

if not defined BROWSER (
    if exist "%ProgramFiles%\Mozilla Firefox\firefox.exe"                set "BROWSER=%ProgramFiles%\Mozilla Firefox\firefox.exe"
    if exist "%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe"           set "BROWSER=%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe"
)

if defined BROWSER (
    echo [信息] 使用浏览器：%BROWSER%
    start "" "%BROWSER%" "%TARGET%"
) else (
    echo [信息] 未检测到 Chrome/Edge/Firefox，使用系统默认浏览器。
    start "" "%TARGET%"
)

echo.
echo 若页面显示邮箱/Google 登录表单即成功；仍是 +86 短信说明当前网络无海外出口。
echo 测试完成后请用记事本（管理员）打开 %HOSTS% 删除 platform.deepseek.com 一行。
pause
