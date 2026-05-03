---
title: 07. Windows Terminal 設定
permalink: /docs/07-WINDOWS-TERMINAL/
nav_order: 70
nav_label: 07. Windows Terminal 設定
---

# 07. Windows Terminal 設定

Codex CLI と Claude Code を WSL Ubuntu と Windows ホストの Git Bash で使うための Windows Terminal 設定。

管理用コピーは `config/windows-terminal/settings.json` に置く。実機の設定ファイルは次の場所にある。

```powershell
$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

## 方針

- 既定プロファイルは WSL Ubuntu にする。
- `Ctrl+C` と `Ctrl+V` は Terminal 側のコピー/ペーストに割り当てる。選択がない `Ctrl+C` はシェルへ送られる。
- 複数行ペーストと大きなペーストの警告は有効にして、AI が生成したコマンドを誤実行しにくくする。
- コピーはプレーンテキストのみ。ANSI 装飾やリッチテキストを混ぜない。
- 透明化と Acrylic は無効にして、長時間のCLI作業で文字の視認性と描画の安定性を優先する。
- `Ctrl` + ホイールのフォントサイズ変更と、`Ctrl+Shift` + ホイールの透明度変更は無効にする。
- Git Bash は `C:\Program Files\Git\bin\bash.exe --login -i` で起動する。
- フォントは Git Bash 側の表示に合わせて `Consolas` を使う。

## 補足

Windows Terminal の実機設定は、ペースト警告を保存時に `warning.largePaste` と `warning.multiLinePaste` へ正規化することがある。公式ドキュメントでは `largePasteWarning` と `multiLinePasteWarning` も説明されているが、このリポジトリでは実機が保存した形式に合わせる。

## 現状確認

```powershell
wsl.exe -l -v
Get-Command wt.exe, git.exe
Get-Content -Raw "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" | ConvertFrom-Json
```

## 適用

`config/windows-terminal/settings.json` を実機の `LocalState\settings.json` に反映する。

```powershell
$source = Resolve-Path .\config\windows-terminal\settings.json
$target = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
Copy-Item $target "$target.bak" -Force
Copy-Item $source $target -Force
```

## 検証

```powershell
Get-Content -Raw "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" | ConvertFrom-Json | Out-Null
```

Windows Terminal を開き直し、既定タブが Ubuntu で起動すること、Git Bash がメニューに表示されること、`Alt+Shift+D` でペイン複製できることを確認する。
