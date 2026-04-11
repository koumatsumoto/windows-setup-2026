# windows-setup-2026

Windows 11 と WSL Ubuntu の開発環境を、依存関係が崩れない順番で構築するための個人用リファレンス。

## ローカル開発

GitHub Pages 互換のローカル確認を前提に、`github-pages` gem を使って起動する。

### 前提

- Ruby
- Bundler

### セットアップ

```bash
./bin/setup-site
```

依存は `vendor/bundle` に閉じる。

### 起動

```bash
./bin/serve-site
```

起動後は `http://127.0.0.1:4000` を開く。

### ビルド確認

```bash
./bin/build-site
```

## 構成

- `_config.yml`
  - サイト全体設定とテーマ設定
- `_layouts/`
  - ページ骨格
- `_includes/`
  - ナビなどの共通部品
- `assets/`
  - CSS と見た目
- `index.md`, `docs/*.md`
  - 公開コンテンツ
- `AUTHORING.md`
  - 運用者向けの theme contract と再利用メモ

## Theme Contract

- ナビ順はファイル名ではなく front matter の `nav_order` で管理する
- ナビ表示名は `nav_label` を使う。未指定時は `title`
- ナビに出さないページは `nav_hidden: true` を使う
- テーマ設定は `_config.yml` の `theme_settings` に置く
- 既存の `/docs/.../` permalink は維持し、本文リンクは `relative_url` を使う

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
| 4 | [docs/04-UBUNTU-SETUP.md](docs/04-UBUNTU-SETUP.md) | Ubuntu 側の Git、gh、fnm、Playwright のセットアップ |
| — | [docs/05-DEV-TOOL-CONFIG.md](docs/05-DEV-TOOL-CONFIG.md) | Git・npm・pip の共通設定（03 と 04 から参照） |
| — | [docs/06-SHELL-CONFIG.md](docs/06-SHELL-CONFIG.md) | .bashrc / .bash_profile の共通設定（03 と 04 から参照） |

## 依存関係

- `docs/02-WINDOWS-SETUP.md` は `docs/01-WINDOWS-CLEAN-INSTALL.md` の完了後に読む
- `docs/03-WINDOWS-DEVELOPMENT-SETUP.md` は `docs/02-WINDOWS-SETUP.md` の完了後に読む
- `docs/04-UBUNTU-SETUP.md` は `docs/03-WINDOWS-DEVELOPMENT-SETUP.md` で Ubuntu の初回起動まで終えてから読む
- Docker Desktop は Windows 側でインストールし、WSL バックエンドを使う前提で運用する

## 横展開するときに持っていくもの

- `_layouts/`
- `_includes/`
- `assets/`
- `_config.yml`
- `Gemfile`
- `bin/setup-site`
- `bin/serve-site`
- `bin/build-site`
- `index.md` をサンプルとして利用

横展開先では、少なくとも次を見直す。

- `title`
- `description`
- `theme_settings.nav_title`
- `theme_settings.mobile_nav_label`
- 各ページの `nav_order`
- 各ページの `nav_label`
- 各ページの `permalink`
