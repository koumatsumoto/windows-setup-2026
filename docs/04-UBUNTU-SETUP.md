---
title: 04. WSL 開発環境
permalink: /docs/04-UBUNTU-SETUP/
nav_order: 40
nav_label: 04. WSL 開発環境
nav_section: setup
---

# 04. WSL 開発環境

`Ubuntu-26.04` に Git / GitHub、Node.js / TypeScript、Python / uv、Playwright の最小基盤を導入します。

## 完了条件

- Git / GitHub CLI と必要最小限の OS パッケージが使える。
- fnm が Node.js LTS を管理し、`node` / `npm` が使える。
- Python はプロジェクトごとに uv で管理できる。
- AI エージェント用 `playwright-cli` と専用 Chromium が使える。
- Playwright Test とそのブラウザーをグローバルには導入していない。

## 1. WSL 基盤を導入する

最初の1回だけ、Windows 側で展開した ZIP のスクリプトを使います。内容を確認し、dry-run、実行の順に進めます。

```bash
cd /mnt/c/Users/kou/Downloads/windows-setup-2026/windows-setup-2026-main
./scripts/wsl/install.sh --dry-run
./scripts/wsl/install.sh
exec bash
```

スクリプトは Ubuntu 26.04 以外では停止します。既存の `.bashrc` 全体は置換せず、管理対象フラグメントを1行だけ source します。変更前の `.bashrc` は初回だけ日時付きでバックアップします。Docker Desktop 連携のために `/etc/wsl.conf` や systemd は変更しません。

## 2. リポジトリを WSL へ clone する

Git の導入後は Windows の ZIP 展開先ではなく、Linux ファイルシステム内で作業します。

```bash
mkdir -p ~/work
cd ~/work
git clone https://github.com/koumatsumoto/windows-setup-2026.git
cd windows-setup-2026
```

以後のコマンドはこの WSL 側コピーで実行します。

## 3. Git と GitHub を設定する

[Git の最小設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) で名前とメールアドレスを設定します。続いて認証します。

```bash
gh auth login
gh auth setup-git
```

トークン、SSH 鍵、認証済み設定はこのリポジトリへ保存しません。

## 4. Node.js / TypeScript

基盤スクリプトは Node.js LTS を導入して既定にします。各プロジェクトは `.node-version` または `.nvmrc` と lockfile を正本にします。

```bash
node --version
node -p 'process.release.lts'
npm --version
```

2行目が `null` ではなく LTS のコードネームを返すことを確認します。TypeScript などは各プロジェクトの `devDependencies` に追加し、グローバル導入しません。

## 5. Python / uv

システム Python やグローバル pip を開発用パッケージで変更しません。新しいプロジェクトでは次のように uv の設定と lockfile を使います。

```bash
uv init example-python
cd example-python
uv python pin 3.14
uv add --dev pytest
uv run pytest
```

Python バージョンは各プロジェクトで決めます。OS セットアップでは特定の Python 系列を先回りして導入しません。

## 6. Playwright の用途を分ける

### プロジェクトの E2E テスト

Playwright Test は対象 Node.js プロジェクトでだけ追加します。

```bash
npm init playwright@latest
npx playwright install --with-deps
npx playwright test
```

`package.json` と lockfile を commit し、必要なブラウザーをそのプロジェクトで取得します。

### AI エージェントのブラウザー操作

基盤スクリプトは `@playwright/cli@latest` と CLI 用 Chromium をグローバル導入します。生成 skill は固定保存せず、Codex / Claude Code から `playwright-cli --help` を読ませます。

```bash
playwright-cli --version
playwright-cli --help
playwright-cli -s=smoke open about:blank
playwright-cli -s=smoke close
```

特定プロジェクトで生成 skill が必要になった場合だけ、その時点の CLI で `playwright-cli install --skills` を実行します。

## 7. read-only 検証

```bash
./scripts/wsl/verify.sh
```

Docker daemon とブラウザーの起動を含む動作確認は、明示的に次を実行します。一時セッションは終了時に閉じます。

```bash
./scripts/wsl/verify-runtime.sh
```

## 次に読む

[05. AI コーディングツールと完了確認]({{ '/docs/08-AI-CODING-TOOLS/' | relative_url }}) に進みます。
