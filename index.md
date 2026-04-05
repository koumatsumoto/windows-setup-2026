---
title: Windows Setup 2026
---

# Windows Setup 2026

Windows 11 と WSL Ubuntu の開発環境を、依存関係が崩れない順番で構築するための手順書です。

## セットアップの流れ

1. Windows をクリーンインストールする
2. Windows の基本設定を行う
3. Windows 側の開発環境と WSL をセットアップする
4. Ubuntu 側の CLI とランタイムをセットアップする

## インデックス

| 順番 | ドキュメント | 役割 |
| ---- | ------------ | ---- |
| 1 | [01. Windows 11 クリーンインストール]({{ '/docs/01-WINDOWS-CLEAN-INSTALL/' | relative_url }}) | Windows 初期インストール、OOBE、アカウント固定、Windows Update |
| 2 | [02. Windows 設定]({{ '/docs/02-WINDOWS-SETUP/' | relative_url }}) | 不要アプリ整理、Microsoft Store 更新、言語と Explorer の設定、Insider Program |
| 3 | [03. Windows 開発環境構築]({{ '/docs/03-WINDOWS-DEVELOPMENT-SETUP/' | relative_url }}) | Windows 側アプリ導入、Git 設定、WSL と Ubuntu の準備 |
| 4 | [04. Ubuntu 側の開発環境セットアップ]({{ '/docs/04-UBUNTU-SETUP/' | relative_url }}) | Ubuntu 側の Git、gh、fnm、Playwright、`grb` のセットアップ |

## 依存関係

- 手順 2 は手順 1 の完了後に進む
- 手順 3 は手順 2 の完了後に進む
- 手順 4 は手順 3 で Ubuntu の初回起動まで終えてから進む
- Docker Desktop は Windows 側でインストールし、WSL バックエンドを使う前提で運用する
