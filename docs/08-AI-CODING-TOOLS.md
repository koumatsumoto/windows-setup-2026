---
title: 08. AI コーディングツール
permalink: /docs/08-AI-CODING-TOOLS/
nav_order: 80
nav_label: 08. AI コーディングツール
---

# 08. AI コーディングツール

WSL Ubuntu で使う AI コーディング CLI ツールのセットアップ手順。

## 前提

- [04. Ubuntu 側の開発環境セットアップ]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) が完了している
- Node.js（fnm）と npm が利用可能である

## このドキュメントの完了条件

- Claude Code または Qwen Code が認証済みで使える
- gh extensions がインストール済みである

## 1. Claude Code

公式手順: https://docs.anthropic.com/en/docs/claude-code

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

初回起動時にブラウザで認証する。

```bash
claude
```

## 2. Qwen Code

```bash
npm install -g @anthropic-ai/claude-code
qwen --version
```

初回起動時にブラウザで認証する。

```bash
qwen
```

## 3. Codex CLI

```bash
npm install -g @openai/codex
codex --version
```

## 4. Antigravity CLI

```bash
curl -fsSL https://raw.githubusercontent.com/antigravity-ai/agy/main/install.sh | sh
agy --version
```

## 5. gh extensions

GitHub CLI の拡張機能を入れる。

```bash
gh extension install github/gh-copilot
gh extension install yusukebe/gh-markdown-preview
```

| 拡張機能 | 用途 |
| --- | --- |
| gh-copilot | GitHub Copilot の CLI 連携（コマンド提案・説明） |
| gh-markdown-preview | Markdown ファイルのブラウザプレビュー |

## 補足

- [07. Windows Terminal 設定]({{ '/docs/07-WINDOWS-TERMINAL/' | relative_url }}) のペースト警告設定は、AI が生成したコマンドの誤実行防止を目的としている
- WSL 側の `BROWSER` 環境変数（[06. シェル初期化設定]({{ '/docs/06-SHELL-CONFIG/' | relative_url }})）が設定済みであれば、認証時のブラウザ起動が Windows 側の既定ブラウザにフォールバックする
