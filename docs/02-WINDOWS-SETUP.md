---
title: 02. Windows 設定
permalink: /docs/02-WINDOWS-SETUP/
---

# 02. Windows 設定

Windows Update 完了後に、日常利用と開発前提の基本設定をまとめて入れる手順。

## 前提

- [01. Windows 11 クリーンインストール]({{ '/docs/01-WINDOWS-CLEAN-INSTALL/' | relative_url }}) が完了している
- Windows Update が完了している

## このドキュメントの完了条件

- 不要アプリのアンインストールが終わっている
- Microsoft Store の更新が終わっている
- 日本語と言語入力まわりの設定が調整済みである
- エクスプローラー設定が完了している
- Windows Insider Program が有効になっている

## 1. 不要アプリのアンインストール

- プリインストールされた不要な Windows アプリを削除する

## 2. Microsoft Store の更新

- Microsoft Store を開き、すべてのアプリを更新する

## 3. 日本語言語設定

- 設定 → 時刻と言語 → 言語と地域 で日本語設定を確認する
- Windows Update 完了後の状態で必要な表示言語と地域設定を調整する

## 4. IME 設定

設定 → 時刻と言語 → 言語と地域 → 日本語 → Microsoft IME → キーとタッチのカスタマイズ を開く。

| キー         | 動作     |
| ------------ | -------- |
| 無変換       | IME オフ |
| 変換         | IME オン |
| Ctrl + Space | なし     |

## 5. エクスプローラー設定

エクスプローラー → 表示 → 表示 から以下を有効にする。

| 項目             | 理由                                    |
| ---------------- | --------------------------------------- |
| ファイル名拡張子 | `.js` / `.ts` / `.env` などの区別に必須 |
| 隠しファイル     | `.gitignore`、`.env` などを表示する     |

## 6. Windows Insider Program の有効化

- 設定から Windows Insider Program を有効化する
- 必要なチャネルは手元の運用方針に合わせて選ぶ

## 次に読む

Windows 側の開発用アプリ導入と WSL 準備は [03. Windows 開発環境構築]({{ '/docs/03-WINDOWS-DEVELOPMENT-SETUP/' | relative_url }}) に進む。
