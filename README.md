# windows-setup-2026

Windows 11 と WSL Ubuntu の開発環境を、依存関係が崩れない順番で構築するための個人用リファレンス。

## 読み方

このリポジトリは 3 段階の手順書で構成する。上から順に進める前提で、各ドキュメントに完了条件と次の読み先を置いている。

## セットアップの流れ

1. Windows をクリーンインストールする
2. Windows 側のツールと WSL をセットアップする
3. Ubuntu 側の CLI とランタイムをセットアップする

## インデックス

| 順番 | ドキュメント | 役割 |
| ---- | ------------ | ---- |
| 1 | [docs/01-WINDOWS-CLEAN-INSTALL.md](docs/01-WINDOWS-CLEAN-INSTALL.md) | Windows 初期インストール、OOBE、アカウント固定、初期設定 |
| 2 | [docs/02-WINDOWS-WSL-SETUP.md](docs/02-WINDOWS-WSL-SETUP.md) | IME 設定、WSL と Ubuntu の導入、Windows 側アプリの導入 |
| 3 | [docs/03-UBUNTU-SETUP.md](docs/03-UBUNTU-SETUP.md) | Ubuntu 側の Git、gh、fnm、Playwright、`grb` のセットアップ |

## 依存関係

- `docs/02-WINDOWS-WSL-SETUP.md` は `docs/01-WINDOWS-CLEAN-INSTALL.md` の完了後に読む
- `docs/03-UBUNTU-SETUP.md` は `docs/02-WINDOWS-WSL-SETUP.md` で Ubuntu の初回起動まで終えてから読む
- Docker Desktop は Windows 側でインストールし、WSL バックエンドを使う前提で運用する
