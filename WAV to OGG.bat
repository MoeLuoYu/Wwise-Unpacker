@echo off

rem 将「WAV」文件夹中的 WAV 转换为 OGG
rem 自动识别格式：标准 PCM WAV（fmt tag=1）用 FFmpeg，Wwise Vorbis WAV 用 ww2ogg + revorb
rem 运行模式：默认显示文件级进度；quiet 参数完全静默；debug 参数显示完整输出
set "OUT=>nul 2>&1"
set "SHOW=echo"
set "CLS=cls"
if /I "%~1"=="quiet" set "SHOW=>nul echo"
if /I "%~1"=="debug" (set "OUT=" & set "SHOW=>nul echo" & set "CLS=>nul ver")

echo 正在转换，请稍候……
ping -n 1 -w 1200 192.0.2.1 >nul

if not exist "WAV" mkdir "WAV"
if not exist "OGG" mkdir "OGG"
set "WMODE=%~1"
set /A TOTAL=0
FOR %%c IN ("WAV\*.WAV") DO (set /A TOTAL+=1)

%CLS% & echo [1/2] 正在识别格式并转换为 OGG...
ping -n 1 -w 800 192.0.2.1 >nul
powershell -NoProfile -Command "(Get-ChildItem -LiteralPath 'WAV' -Filter *.wav).ForEach({ $tag=[BitConverter]::ToUInt16([IO.File]::ReadAllBytes($_.FullName),20); if ($tag -eq 1) { if ($env:WMODE -ne 'quiet') { Write-Host ('    转换[PCM] ' + $_.Name) }; $o = & 'Tools\ffmpeg.exe' -i $_.FullName -acodec libvorbis -q:a 6 -y ('OGG\' + $_.BaseName + '.ogg') 2>&1; if ($env:WMODE -eq 'debug') { $o | Write-Host } } else { if ($env:WMODE -ne 'quiet') { Write-Host ('    转换[Wwise] ' + $_.Name) }; $o = & 'Tools\ww2ogg.exe' $_.FullName --pcb 'Tools\packed_codebooks_aoTuV_603.bin' 2>&1; if ($env:WMODE -eq 'debug') { $o | Write-Host } } })"
%CLS% & echo [2/2] 正在修复 Wwise OGG 索引并移动文件...
FOR %%d IN ("WAV\*.OGG") DO ("Tools\revorb.exe" "%%d" %OUT% & MOVE "%%d" "OGG" %OUT%)
ping -n 1 -w 800 192.0.2.1 >nul & %CLS%
echo -------------------------------------------------------------

echo 转换完成！共处理 %TOTAL% 个文件，已保存到「OGG」文件夹

echo -------------------------------------------------------------
echo.
pause
