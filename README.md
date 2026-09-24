# Wwise-Unpacker（Wwise 解包器）
解包游戏音频 Wwise 文件（PCK、BNK、WEM）

> ⚠️ **重要提示**：由于 Git 会将批处理脚本（.bat）的换行符改为 LF，请您在下载到本地使用前，将脚本转换为 CRLF 换行，否则脚本可能运行异常。
>
> 在本目录下打开 PowerShell 或命令行，执行以下命令即可一次性转换全部三个脚本（同时保持 GBK 编码不变）：
>
> ```
> powershell -NoProfile -Command "Get-ChildItem *.bat | ForEach-Object { $e=[Text.Encoding]::GetEncoding(936); $t=[IO.File]::ReadAllText($_.FullName,$e).Replace(\"`r`n\",\"`n\").Replace(\"`n\",\"`r`n\"); [IO.File]::WriteAllText($_.FullName,$t,$e) }"
> ```
>
> 也可以用 Git 自带工具（CMD 中执行）：
>
> ```
> for %f in (*.bat) do unix2dos "%f"
> ```

**本教程仅适用于 Windows 64 位系统！** 我将以《植物大战僵尸 2》中文版（iOS）**作为示例**。

目录结构如下：

* Wwise Unpacker（解包器主目录）
  * MP3（解包出的 MP3 文件）
  * OGG（解包出的 OGG 文件）
  * WAV（解包出的原始 WAV 文件）
  * Game Files（存放 PCK、BNK 和 WEM 文件）
  * Tools（解包过程用到的工具）
  * Unpack to MP3.bat（解包为 MP3 脚本）
  * Unpack to OGG.bat（解包为 OGG 脚本）
  * Unpack to WAV.bat（仅解包、不转换格式）

现在我们需要找到要解包的音频文件。《植物大战僵尸 2》使用 Wwise 音频，资源以 RSB 格式打包，但不同平台 / 版本的存放方式不同：

* **iOS**（国际版和中文版相同）：全部资源在单个 `main.rsb` 中，位于应用目录内。
* **安卓中文版**：资源可能被拆分为多个 `.rsb` 文件。
* **安卓国际版**：为单个 `main.<内部版本号>.com.ea.game.pvz2_<区域版本>.obb` 文件（文件格式仍然是 RSB，只是扩展名不同）。

用 RSB 解包工具（如 RSB Unpacker 等）将其解开，得到类似下面的目录结构（以中文版 iOS 为例）：

* main（main.rsb 解包后的目录）
  * EGYPT_SOUNDBANKS、PIRATE_SOUNDBANKS、COWBOY_SOUNDBANKS 等（各世界的 BNK 音频容器）
  * EGYPT_STREAMINGWAVES、PIRATE_STREAMINGWAVES 等（各世界的 WEM 音频流）
  * PLANT1/2_SOUNDBANKS、ZOMBIE1/2/3_SOUNDBANKS（植物 / 僵尸相关音效）
  * BGMA~E_SOUNDBANKS（背景音乐）
  * INIT_SOUNDBANKS（初始化与杂项音效）

其中：

* `*_SOUNDBANKS` 文件夹里是 `.BNK` 容器（如 `EGYPT_MUSIC.BNK`、`CRAZY_DAVE.BNK`），文件名能看出对应的世界和用途。
* `*_STREAMINGWAVES` 文件夹按音库名再分一层子目录（如 `EGYPT_STREAMINGWAVES\EGYPT_MUSIC\`），里面是纯数字命名的 `.WEM` 文件（如 `158484045.WEM`）。WEM 是单条音频流，命名是资源 ID，没有语义信息。

注意 BNK 是容器，里面可能包含多条音频事件；WEM 则是直接的音频数据。两者都可以直接复制到 "Game Files" 文件夹里让解包器处理。中文版与国际版的目录结构可能略有差异，但音频格式一致。

把你想要解码的容器复制到 Wwise Unpacker 的 "Game Files" 文件夹里（PCK、BNK 或 WEM 均可，解包器都能处理），然后根据你的需求双击运行对应的脚本，剩下的事情交给它就行了：
"Unpack to MP3.bat"、"Unpack to OGG.bat" 或 "Unpack to WAV.bat"（只做原始解包、不做格式转换）。
完成后，所有解码好的文件分别在 "MP3"、"OGG" 或 "WAV" 文件夹里。

**脚本参数（可选）：**

脚本支持两种可选参数，在命令行中运行脚本时附带即可（直接双击运行则为默认模式）：

* 默认（无参数）：显示分步进度和正在处理的文件名，隐藏工具的详细输出。
* `quiet`：完全静默运行，只显示分步提示和最终结果。用法示例：
  ```
  "Unpack to OGG.bat" quiet
  ```
* `debug`：显示工具的完整输出且不清屏（完整保留所有步骤的屏幕记录），方便排查问题（如某个文件解码失败时）。用法示例：
  ```
  "Unpack to OGG.bat" debug
  ```

**关于解码器的几点说明：**

* 取决于文件的数量和大小，解码可能需要一段时间，请耐心等待各步骤跑完。
* 解码器会询问是否删除 "Game Files" 中的源文件，避免你不小心重复解码同一批文件（按 Y 或 N 单键确认）。
* 脚本在转换/整理阶段会按文件内容自动去重：内容完全相同的音频只保留一份，直接跳过重复项。真实文件名本身以 _数字 结尾的文件（如 ..._200.ogg）只要内容不同就不会被误删。
* 解码为 MP3 时，文件会先被解包成 OGG，再通过 FFmpeg 和 LAME MP3 编码器转换。如果想要尽可能高的质量，请不要选 MP3，直接解包为 OGG。
* 用 "Unpack to WAV.bat" 解包出的是 Wwise 原始编码的 WAV，普通播放器可能无法直接播放，适合需要自行处理原始数据的场景。
* 本解包器适用于任何使用 Wwise 音频的游戏，不限于《植物大战僵尸 2》。

**我解包出了 .OGG 以获得最佳质量，可是这些文件要怎么打开？**

你需要一个支持该格式的播放器！我个人使用 [PotPlayer](https://apps.microsoft.com/detail/xp8bsbgqw2dks0)，不过你也可以自行搜索，找到最适合你的播放器。

---

如果你用这些音频做了什么（比如剪辑视频），请告诉我，我非常乐意看到其他人的作品。希望这个工具能帮到你！
