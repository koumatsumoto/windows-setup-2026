---
title: Windows Setup 2026
---

# Windows Setup 2026

Windows 11 と WSL Ubuntu の開発環境を、依存関係が崩れない順番で構築するための手順書です。

## セットアップの流れ

1. Windows をクリーンインストールする
2. Windows 側のツールと WSL をセットアップする
3. Ubuntu 側の CLI とランタイムをセットアップする

## インデックス

| 順番 | ドキュメント | 役割 |
| ---- | ------------ | ---- |
| 1 | [01. Windows 11 クリーンインストール]({{ '/docs/01-WINDOWS-CLEAN-INSTALL/' | relative_url }}) | Windows 初期インストール、OOBE、アカウント固定、初期設定 |
| 2 | [02. Windows 側セットアップと WSL 準備]({{ '/docs/02-WINDOWS-WSL-SETUP/' | relative_url }}) | IME 設定、WSL と Ubuntu の導入、Windows 側アプリの導入 |
| 3 | [03. Ubuntu 側の開発環境セットアップ]({{ '/docs/03-UBUNTU-SETUP/' | relative_url }}) | Ubuntu 側の Git、gh、fnm、Playwright、`grb` のセットアップ |

## 依存関係

- 手順 2 は手順 1 の完了後に進む
- 手順 3 は手順 2 で Ubuntu の初回起動まで終えてから進む
- Docker Desktop は Windows 側でインストールし、WSL バックエンドを使う前提で運用する
