---
title: 03. Windows 開発環境構築
permalink: /docs/03-WINDOWS-DEVELOPMENT-SETUP/
nav_order: 30
nav_label: 03. Windows 開発環境構築
---

# 03. Windows 開発環境構築

Windows 側で使うアプリを入れ、WSL と Ubuntu を開発用に使える状態にする手順。

基本的な開発は Ubuntu 側で進める前提だが、Flutter など一部のアプリは Windows 側で開発する場合があるため、Windows 側の Git もここでセットアップする。

## 前提

- [02. Windows 設定]({{ '/docs/02-WINDOWS-SETUP/' | relative_url }}) が完了している

## このドキュメントの完了条件

- Git、VS Code、Docker Desktop など Windows 側アプリが入っている
- Windows Terminal の既定プロファイルが Ubuntu（WSL）になっている
- [06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }}) の Windows 向け手順が完了している
- [05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の Windows 向け手順が完了している
- WSL と Ubuntu がインストール済みである
- Ubuntu を初回起動し、Linux ユーザー作成まで終わっている
- Docker Desktop の WSL 統合が有効になっている
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
winget install -e --id Microsoft.PowerToys
winget install -e --id Microsoft.Edit
winget install -e --id GitHub.cli
winget install -e --id Schniz.fnm
winget install -e --id Python.Python.3.14
```

| winget ID | 用途 |
| --- | --- |
| Microsoft.PowerToys | ウィンドウ管理（FancyZones）、ランチャー（PowerToys Run）等 |
| Microsoft.Edit | ターミナル用エディタ。WSL 側の `msedit` スクリプトから参照する |
| GitHub.cli | Windows 側からの GitHub CLI 操作（`gh`） |
| Schniz.fnm | Windows 側の Node.js バージョン管理 |
| Python.Python.3.14 | Windows 側の Python ランタイム |

### すべてのアプリを更新

```powershell
winget upgrade --all
```

## 2. Windows Terminal の設定

既定プロファイルを Ubuntu（WSL）にし、Git Bash プロファイルを追加する。詳細は [07. Windows Terminal 設定]({{ '/docs/07-WINDOWS-TERMINAL/' | relative_url }}) を参照。

### Git Bash プロファイルの追加

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

### 既定プロファイルの確認

設定画面の「スタートアップ」→「既定のプロファイル」で「Ubuntu」が選択されていることを確認する。WSL インストール後は Ubuntu が既定になる。

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

## 7. Docker Desktop の WSL 統合

Docker Desktop が WSL2 バックエンドで動作するように設定する。

1. Docker Desktop を起動する
2. Settings（歯車アイコン）→ **Resources** → **WSL Integration** を開く
3. 「Enable integration with my default WSL distro」を有効にする
4. 一覧から Ubuntu のトグルを有効にする
5. **Apply & Restart** をクリックする

WSL 内で確認する。

```bash
docker --version
docker compose version
```

Docker CLI は `/mnt/wsl/docker-desktop/cli-tools/` 経由で WSL 内に提供される。apt での Docker Engine インストールは不要。

## 8. VS Code と WSL の連携

1. Windows 側で VS Code を起動する
2. WSL 内でプロジェクトディレクトリに移動する
3. 以下を実行する

```bash
code .
```

初回実行時に VS Code Server と WSL 拡張機能（Remote - WSL）が自動でインストールされる。

## 次に読む

Ubuntu 側の CLI とランタイムのセットアップは [04. Ubuntu 側の開発環境セットアップ]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) に進む。
