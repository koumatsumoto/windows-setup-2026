---
title: 04. Ubuntu 側の開発環境セットアップ
permalink: /docs/04-UBUNTU-SETUP/
nav_order: 40
nav_label: 04. Ubuntu 側の開発環境セットアップ
---

# 04. Ubuntu 側の開発環境セットアップ

WSL 上の Ubuntu に、開発で使う CLI とランタイムを入れる手順。

## 前提

- [03. Windows 開発環境構築]({{ '/docs/03-WINDOWS-DEVELOPMENT-SETUP/' | relative_url }}) が完了している
- Ubuntu を起動し、Linux ユーザーが作成済みである

## このドキュメントの完了条件

- Ubuntu 側で Git と GitHub CLI が使える
- systemd が有効になっている
- Node.js 開発に必要な基本パッケージが入っている
- fnm がインストール済みである
- [05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の Ubuntu 向け手順が完了している
- [06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }}) の Ubuntu 向け手順が完了している

## 1. パッケージ更新

```bash
sudo apt update -y && sudo apt full-upgrade -y
```

## 2. systemd 有効化

WSL で systemd を有効にする。Docker Desktop の WSL 統合やサービス管理に必要。

```bash
sudo tee /etc/wsl.conf > /dev/null <<'EOF'
[boot]
systemd=true
EOF
```

設定を反映するために Windows 側で WSL を再起動する。

```powershell
wsl --shutdown
```

Ubuntu を再起動し、systemd が動作していることを確認する。

```bash
systemctl list-units --type=service --state=running | head
```

## 3. Git インストール

```bash
sudo apt install -y git
```

## 4. GitHub CLI（gh）

公式手順: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

インストール後に認証する。

```bash
gh auth login
gh auth setup-git
```

## 5. Node.js 開発の基本パッケージ

`fnm` の導入とネイティブモジュールのビルドに必要なパッケージ:

```bash
sudo apt install -y curl unzip build-essential python3
```

| パッケージ      | 用途                                         |
| --------------- | -------------------------------------------- |
| curl            | `fnm` インストールスクリプトのダウンロード   |
| unzip           | `fnm` パッケージの展開                       |
| build-essential | ネイティブモジュール（node-gyp）のコンパイル |
| python3         | node-gyp 10+ で必須                          |

## 6. Node.js バージョン管理（fnm）

公式手順: https://github.com/Schniz/fnm

fnm をインストールする。シェルの初期化（`eval "$(fnm env ...)"` の `.bashrc` 追加）は [06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }}) で行う。

## 7. シェル初期化設定

[06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }}) の手順を Ubuntu のターミナルで実行し、完了後このドキュメントに戻る。

設定を反映するためにシェルを再読み込みする。

```bash
source ~/.bashrc
```

## 8. Node.js のインストール

Playwright や `npx` を使う前に、`fnm` で Node.js を 1 系列インストールして有効化する。

```bash
fnm install --lts
fnm default lts-latest
node -v
npx -v
```

## 9. 開発ツール共通設定

vim が入っていない場合は先にインストールする。

```bash
sudo apt install -y vim
```

[05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) の Ubuntu 向け手順を実行し、完了後このドキュメントに戻る。

## 10. Playwright ブラウザ依存パッケージ

Node.js インストール後に依存パッケージをインストールする。

```bash
npx playwright install-deps
npx playwright install
```

## 11. 追加の開発ツール

必須ではないが、開発で使うツールをまとめて入れる。

### Rust

公式手順: https://rustup.rs

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustc --version
```

### uv（Python パッケージ管理）

公式手順: https://docs.astral.sh/uv/

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source "$HOME/.local/bin/env"
uv --version
```

### Google Cloud SDK

公式手順: https://cloud.google.com/sdk/docs/install?hl=ja

```bash
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update && sudo apt install -y google-cloud-cli
gcloud --version
```

### kubectl

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubectl
kubectl version --client
```

### corepack（pnpm / yarn）

Node.js に同梱されている corepack を有効化する。

```bash
corepack enable
pnpm --version
```

### wrangler（Cloudflare Workers）

```bash
npm install -g wrangler
wrangler --version
```

### Google Chrome（WSL 内ブラウザテスト用）

```bash
wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y /tmp/google-chrome.deb
rm /tmp/google-chrome.deb
google-chrome --version
```

Playwright のブラウザテストでシステム Chrome を使う場合に必要。
