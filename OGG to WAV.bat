@echo off

rem 将「OGG」文件夹中的 OGG 解码为标准 PCM WAV（FFmpeg）
rem 注意：输出的 WAV 为标准 PCM 格式，与「Unpack to WAV」解包出的 Wwise 原始 WAV 不同
rem 运行模式：默认显示文件级进度；quiet 参数完全静默；debug 参数显示完整输出
set "OUT=>nul 2>&1"
set "SHOW=echo"
set "CLS=cls"
if /I "%~1"=="quiet" set "SHOW=>nul echo"
if /I "%~1"=="debug" (set "OUT=" & set "SHOW=>nul echo" & set "CLS=>nul ver")

echo 正在转换，请稍候……
ping -n 1 -w 1200 192.0.2.1 >nul

if not exist "OGG" mkdir "OGG"
if not exist "WAV" mkdir "WAV"
set /A TOTAL=0

%CLS% & echo [1/1] 正在将 OGG 解码为 WAV...
ping -n 1 -w 800 192.0.2.1 >nul
FOR %%c IN ("OGG\*.OGG") DO (set /A TOTAL+=1 & %SHOW%    解码 %%~nxc & "Tools\ffmpeg.exe" -i "%%c" -acodec pcm_s16le -y "WAV\%%~nc.wav" %OUT%)
ping -n 1 -w 800 192.0.2.1 >nul & %CLS%
echo -------------------------------------------------------------

echo 转换完成！共处理 %TOTAL% 个文件，已保存到「WAV」文件夹

echo -------------------------------------------------------------
echo.
pause
