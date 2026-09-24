@echo off

rem 运行模式：默认显示文件级进度；quiet 参数完全静默；debug 参数显示完整输出
set "OUT=>nul 2>&1"
set "SHOW=echo"
set "CLS=cls"
if /I "%~1"=="quiet" set "SHOW=>nul echo"
if /I "%~1"=="debug" (set "OUT=" & set "SHOW=>nul echo" & set "CLS=>nul ver")

echo 正在解包，请稍候……
ping -n 1 -w 1200 192.0.2.1 >nul

%CLS% & echo [1/4] 使用 quickbms 扫描提取音频流...
ping -n 1 -w 800 192.0.2.1 >nul
"Tools\quickbms.exe" -q -o "Tools\wavescan.bms" "Game Files" "Tools\Decoding" %OUT%
chcp 936 >nul
%CLS% & echo [2/4] 正在解包 BNK 容器并收集 WEM 文件...
ping -n 1 -w 800 192.0.2.1 >nul
FOR %%b IN ("Game Files\*.BNK") DO (%SHOW%    解包 %%~nxb & "Tools\bnkextr.exe" "%%b" %OUT% & MOVE *.wav "Tools\Decoding" %OUT%)
FOR %%w IN ("Game Files\*.WEM") DO (COPY /Y "%%w" "Tools\Decoding\%%~nw.wav" >nul)
%CLS% & echo [3/4] 正在将 Wwise 音频转换为 OGG（文件较多时需要一些时间）...
set "WMODE=%~1"
set "WWCNT=%TEMP%\ww2ogg_count.tmp"
powershell -NoProfile -Command "$c=0;$s=0;$h=@{}; (Get-ChildItem -LiteralPath 'Tools\Decoding' -Filter *.wav).ForEach({ $k=(Get-FileHash -LiteralPath $_.FullName).Hash; if ($h.ContainsKey($k)) { $s++ } else { $h[$k]=1; if ($env:WMODE -ne 'quiet') { Write-Host ('    转换 ' + $_.Name) }; $o = & 'Tools\ww2ogg.exe' $_.FullName --pcb 'Tools\packed_codebooks_aoTuV_603.bin' 2>&1; if ($env:WMODE -eq 'debug') { $o | Write-Host }; Remove-Item -LiteralPath $_.FullName; $c++ } }); Set-Content -LiteralPath $env:WWCNT -Value ($c.ToString() + ' ' + $s.ToString())"
FOR /F "tokens=1,2" %%a IN ('type "%TEMP%\ww2ogg_count.tmp"') DO (SET CV=%%a & SET SK=%%b)
DEL "%TEMP%\ww2ogg_count.tmp" >nul 2>&1
DEL /Q "Tools\Decoding\*.WAV" >nul 2>&1
echo 本步转换 %CV% 个文件，跳过 %SK% 个重复
ping -n 1 -w 800 192.0.2.1 >nul
%CLS% & echo [4/4] 正在修复 OGG 索引并移动文件...
FOR %%d IN (Tools\Decoding\*.OGG) DO (%SHOW%    修复 %%~nxd & "Tools\revorb.exe" "%%d" %OUT% & MOVE "%%d" "OGG" %OUT%)
ping -n 1 -w 800 192.0.2.1 >nul & %CLS%
echo -------------------------------------------------------------

echo 解包完成！文件已保存到「OGG」文件夹

echo -------------------------------------------------------------
echo.

:choice
choice /C YN /M "是否删除「Game Files」文件夹中的 BNK、PCK 和 WEM 文件"
if errorlevel 2 (
echo 已保留源文件，祝你听歌愉快！
) else (
FOR %%e IN ("Game Files\*.PCK") DO (DEL "%%e")
FOR %%f IN ("Game Files\*.BNK") DO (DEL "%%f")
FOR %%g IN ("Game Files\*.WEM") DO (DEL "%%g")
echo 文件已删除，祝你听歌愉快！
)
pause
