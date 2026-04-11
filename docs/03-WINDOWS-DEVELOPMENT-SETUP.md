---
title: 03. Windows 開発環境構築
permalink: /docs/03-WINDOWS-DEVELOPMENT-SETUP/
---

# 03. Windows 開発環境構築

Windows 側で使うアプリを入れ、WSL と Ubuntu を開発用に使える状態にする手順。

基本的な開発は Ubuntu 側で進める前提だが、Flutter など一部のアプリは Windows 側で開発する場合があるため、Windows 側の Git もここでセットアップする。

## 前提

- [02. Windows 設定]({{ '/docs/02-WINDOWS-SETUP/' | relative_url }}) が完了している

## このドキュメントの完了条件

- Git、VS Code、Docker Desktop など Windows 側アプリが入っている
- Windows Terminal の既定プロファイルが Git Bash に変更されている
- [06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }}) の Windows 向け手順が完了している
- [05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の Windows 向け手順が完了している
- WSL と Ubuntu がインストール済みである
- Ubuntu を初回起動し、Linux ユーザー作成まで終わっている
- VS Code と WSL の連携が完了している

## 1. winget でアプリインストール

PowerShell で実行する。

```powershell
winget install -e --id Git.Git
winget install -e --id Google.Chrome
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Docker.DockerDesktop
winget install -e --id Oracle.MySQLWorkbench
winget install -e --id Logitech.GHUB
winget install -e --id Discord.Discord
winget install -e --id 7zip.7zip
```

### すべてのアプリを更新

```powershell
winget upgrade --all
```

## 2. Windows Terminal の Git Bash 設定

Windows Terminal の既定プロファイルを Git Bash に変更する。

### プロファイルの追加

1. Windows Terminal を開く
2. `Ctrl + ,` で設定画面を開く
3. 左下の「JSON ファイルを開く」をクリックする
4. `profiles.list` 配列に以下のプロファイルを追加する

```json
{
    "name": "Git Bash",
    "commandline": "C:\\Program Files\\Git\\bin\\bash.exe --login -i",
    "icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
    "startingDirectory": "%USERPROFILE%"
}
```

### 既定プロファイルの変更

設定画面の「スタートアップ」→「既定のプロファイル」で「Git Bash」を選択する。

### bash.exe と git-bash.exe の違い

| 実行ファイル | 動作 |
| --- | --- |
| `C:\Program Files\Git\bin\bash.exe` | Windows Terminal のタブ内で動作する |
| `C:\Program Files\Git\git-bash.exe` | 独立したウィンドウ（MinTTY）で開く |

Windows Terminal で使う場合は `bash.exe` を指定する。`git-bash.exe` を指定すると別ウィンドウが開き、Terminal のタブとして統合されない。

`--login -i` を付けることでログインシェルとして起動し、`.bash_profile` が読み込まれるようになる。

## 3. シェル初期化設定

Git Bash で [06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }}) の手順を実行する。

## 4. 開発ツール共通設定

Git Bash で [05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の手順を実行する。事前に `vim --version` で vim が利用可能なことを確認する。

## 5. WSL インストール

PowerShell を管理者で開いて実行する。

```powershell
wsl --install
```

Ubuntu を明示する場合:

```powershell
wsl --install -d Ubuntu
```

インストール後、PC を再起動する。

### 補足

- `wsl --install` は Ubuntu を既定のディストリビューションとして入れる
- すでに WSL が入っていてヘルプが出る場合は `wsl --list --online` で利用可能なディストリビューションを確認する

## 6. Ubuntu の初回起動

1. スタートメニューから `Ubuntu` を起動する
2. 展開完了を待つ
3. Linux 側のユーザー名とパスワードを設定する

ここまで終わると、Ubuntu 側のセットアップを始められる。

## 7. VS Code と WSL の連携

1. Windows 側で VS Code を起動する
2. WSL 内でプロジェクトディレクトリに移動する
3. 以下を実行する

```bash
code .
```

初回実行時に VS Code Server と WSL 拡張機能（Remote - WSL）が自動でインストールされる。

## 次に読む

Ubuntu 側の CLI とランタイムのセットアップは [04. Ubuntu 側の開発環境セットアップ]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に進む。
