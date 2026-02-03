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
winget install -e --id 7zip.7zip
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
git config --global user.name "Name"
git config --global user.email "Email"
```

### GitHub CLI（gh）

公式手順: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

インストール後、認証:

```bash
gh auth login
```

Git の認証情報を gh 経由で設定:

```bash
gh auth setup-git
```

### Node.js 開発の基本パッケージ

fnm（Node.js バージョン管理）のインストールとネイティブモジュールのビルドに必要なパッケージ:

```bash
sudo apt install -y curl unzip build-essential python3
```

| パッケージ      | 用途                                         |
| --------------- | -------------------------------------------- |
| curl            | fnm インストールスクリプトのダウンロード     |
| unzip           | fnm パッケージの展開                         |
| build-essential | ネイティブモジュール（node-gyp）のコンパイル |
| python3         | node-gyp 10+ で必須                          |

### Node.js バージョン管理（fnm）

公式手順: https://github.com/Schniz/fnm

インストール後、シェル設定ファイル（`.bashrc` / `.zshrc`）に以下を追加:

```bash
eval "$(fnm env --use-on-cd)"
```

### Playwright ブラウザ依存パッケージ

Node.js インストール後に自動で依存パッケージをインストール:

```bash
npx playwright install-deps
```

## 5. VSCode と WSL の連携

WSL 内のプロジェクトを VSCode で開く。

### 初回セットアップ

WSL 内でプロジェクトディレクトリに移動し、以下を実行:

```bash
code .
```

初回実行時に VSCode Server と WSL 拡張機能（Remote - WSL）が自動でインストールされる。

以降は `code .` で WSL 内のプロジェクトを直接 VSCode で編集可能。

## 6. Git カスタマイズ

### grb コマンド（Git Refresh Branch）

main ブランチに戻り、最新を取得し、マージ済みのローカルブランチを削除するコマンド。

`.bashrc` または `.zshrc` に追加:

```bash
grb() {
  git switch main && git pull origin main && git branch --merged main | grep -v "^[* ]*main$" | xargs -r git branch -d
}
```
