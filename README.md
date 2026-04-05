# windows-setup-2026

Windows 11 と WSL Ubuntu の開発環境を、依存関係が崩れない順番で構築するための個人用リファレンス。

## 読み方

このリポジトリは 4 段階の手順書で構成する。上から順に進める前提で、各ドキュメントに完了条件と次の読み先を置いている。

## セットアップの流れ

1. Windows をクリーンインストールする
2. Windows の基本設定を行う
3. Windows 側の開発環境と WSL をセットアップする
4. Ubuntu 側の CLI とランタイムをセットアップする

## インデックス

| 順番 | ドキュメント | 役割 |
| ---- | ------------ | ---- |
| 1 | [docs/01-WINDOWS-CLEAN-INSTALL.md](docs/01-WINDOWS-CLEAN-INSTALL.md) | Windows 初期インストール、OOBE、アカウント固定、Windows Update |
| 2 | [docs/02-WINDOWS-SETUP.md](docs/02-WINDOWS-SETUP.md) | 不要アプリ整理、Microsoft Store 更新、言語と Explorer の設定、Insider Program |
| 3 | [docs/03-WINDOWS-DEVELOPMENT-SETUP.md](docs/03-WINDOWS-DEVELOPMENT-SETUP.md) | Windows 側アプリ導入、Git 設定、WSL と Ubuntu の準備 |
| 4 | [docs/04-UBUNTU-SETUP.md](docs/04-UBUNTU-SETUP.md) | Ubuntu 側の Git、gh、fnm、Playwright、`grb` のセットアップ |

## 依存関係

- `docs/02-WINDOWS-SETUP.md` は `docs/01-WINDOWS-CLEAN-INSTALL.md` の完了後に読む
- `docs/03-WINDOWS-DEVELOPMENT-SETUP.md` は `docs/02-WINDOWS-SETUP.md` の完了後に読む
- `docs/04-UBUNTU-SETUP.md` は `docs/03-WINDOWS-DEVELOPMENT-SETUP.md` で Ubuntu の初回起動まで終えてから読む
- Docker Desktop は Windows 側でインストールし、WSL バックエンドを使う前提で運用する
