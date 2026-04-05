# 02. Windows 側セットアップと WSL 準備

Windows の初期インストール後に、開発用アプリと WSL を使える状態にする手順。

## 前提

- `01-WINDOWS-CLEAN-INSTALL.md` が完了している
- Windows Update が完了している

## このドキュメントの完了条件

- IME 設定が調整済みである
- WSL と Ubuntu がインストール済みである
- Git、VS Code、Docker Desktop など Windows 側アプリが入っている
- Ubuntu を初回起動し、Linux ユーザー作成まで終わっている

## 1. IME 設定

設定 → 時刻と言語 → 言語と地域 → 日本語 → Microsoft IME → キーとタッチのカスタマイズ を開く。

| キー         | 動作     |
| ------------ | -------- |
| 無変換       | IME オフ |
| 変換         | IME オン |
| Ctrl + Space | なし     |

## 2. WSL インストール

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

## 3. Ubuntu の初回起動

1. スタートメニューから `Ubuntu` を起動する
2. 展開完了を待つ
3. Linux 側のユーザー名とパスワードを設定する

ここまで終わると、Ubuntu 側のセットアップを始められる。

## 4. winget でアプリインストール

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

## 5. VS Code と WSL の連携

1. Windows 側で VS Code を起動する
2. WSL 内でプロジェクトディレクトリに移動する
3. 以下を実行する

```bash
code .
```

初回実行時に VS Code Server と WSL 拡張機能（Remote - WSL）が自動でインストールされる。

## 次に読む

Ubuntu 側の CLI とランタイムのセットアップは `03-UBUNTU-SETUP.md` に進む。
