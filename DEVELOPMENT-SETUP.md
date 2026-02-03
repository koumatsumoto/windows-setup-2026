# 開発環境の初期セットアップ

## 1. IME 設定

最初にキーボード設定を行う。

### 手順

設定 → 時刻と言語 → 言語と地域 → 日本語 → Microsoft IME → キーとタッチのカスタマイズ

### キー設定

| キー         | 動作     |
| ------------ | -------- |
| 無変換       | IME オフ |
| 変換         | IME オン |
| Ctrl + Space | なし     |

## 2. WSL インストール

### PowerShell（管理者）で実行

```powershell
wsl --install
```

または、ディストリビューションを指定:

```powershell
wsl --install -d Ubuntu
```

インストール後、PC を再起動。

## 3. winget でアプリインストール

### PowerShell で実行

```powershell
winget install -e --id Git.Git
winget install -e --id Google.Chrome
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Docker.DockerDesktop
winget install -e --id Oracle.MySQLWorkbench
winget install -e --id Logitech.GHUB
winget install -e --id Discord.Discord
```

### すべてのアプリを更新

```powershell
winget upgrade --all
```

## 4. WSL（Ubuntu）側セットアップ

### パッケージ更新

```bash
sudo apt update -y && sudo apt full-upgrade -y
```

### Git インストール

```bash
sudo apt install -y git
```

### Git グローバル設定

```bash
git config --global user.name "Kou Matsumoto"
git config --global user.email "kou.matsumoto.jp@gmail.com"
```

### GitHub CLI（gh）

公式手順: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

インストール後、認証:

```bash
gh auth login
```

### Node.js バージョン管理（fnm）

公式手順: https://github.com/Schniz/fnm

インストール後、シェル設定ファイル（`.bashrc` / `.zshrc`）に設定を追加。
