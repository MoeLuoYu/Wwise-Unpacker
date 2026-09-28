@echo off

rem 将「MP3」文件夹中的 MP3 转码为 OGG（FFmpeg + Vorbis）
rem 运行模式：默认显示文件级进度；quiet 参数完全静默；debug 参数显示完整输出
set "OUT=>nul 2>&1"
set "SHOW=echo"
set "CLS=cls"
if /I "%~1"=="quiet" set "SHOW=>nul echo"
if /I "%~1"=="debug" (set "OUT=" & set "SHOW=>nul echo" & set "CLS=>nul ver")

echo 正在转换，请稍候……
ping -n 1 -w 1200 192.0.2.1 >nul

if not exist "MP3" mkdir "MP3"
if not exist "OGG" mkdir "OGG"
set /A TOTAL=0

%CLS% & echo [1/1] 正在将 MP3 转码为 OGG...
ping -n 1 -w 800 192.0.2.1 >nul
FOR %%c IN ("MP3\*.MP3") DO (set /A TOTAL+=1 & %SHOW%    转码 %%~nxc & "Tools\ffmpeg.exe" -i "%%c" -acodec libvorbis -q:a 6 -y "OGG\%%~nc.ogg" %OUT%)
ping -n 1 -w 800 192.0.2.1 >nul & %CLS%
echo -------------------------------------------------------------

echo 转换完成！共处理 %TOTAL% 个文件，已保存到「OGG」文件夹

echo -------------------------------------------------------------
echo.
pause
