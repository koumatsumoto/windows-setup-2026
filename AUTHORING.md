# Site Authoring Guide

このファイルはサイト運用者向けのメモであり、Jekyll サイトのナビには表示しない。

## Theme Contract

- `_config.yml`
  - サイト全体設定とテーマ設定を置く
  - `theme_settings.nav_title`, `theme_settings.mobile_nav_label`, `theme_settings.docs_path_prefix`, `theme_settings.show_build_time` をここで管理する
- front matter
  - ページごとのナビ情報を置く
  - `nav_order`: ナビ並び順の single source of truth
  - `nav_label`: ナビ表示名。未指定時は `title`
  - `nav_hidden`: `true` の場合はナビ非表示
- `_layouts/default.html`
  - 共通フレームのみを持つ
- `_includes/site-nav-links.html`
  - ナビ描画の責務だけを持つ
- `assets/css/style.scss`
  - テーマの見た目を定義する

## Authoring Rules

- 公開ページは front matter を必ず付ける
- ナビへ出すページは `nav_order` を必ず付ける
- ナビの順番はファイル名ではなく `nav_order` で管理する
- `nav_label` はメニューでの読みやすさを優先してよい
- ナビに出さない補助文書は front matter を付けないか、`nav_hidden: true` を使う
- `permalink` は既存の `/docs/.../` 形式を維持する

## Reuse Checklist

- 他リポジトリへ持っていく最小単位
  - `_layouts/`
  - `_includes/`
  - `assets/`
  - `_config.yml`
  - `Gemfile`
  - `compose.yaml`
  - `bin/setup-site`
  - `bin/serve-site`
  - `bin/build-site`
- 取り込み後に見直す設定
  - `title`
  - `description`
  - `theme_settings.nav_title`
  - `theme_settings.mobile_nav_label`
  - `theme_settings.docs_path_prefix`
  - 各ページの `nav_order`, `nav_label`, `permalink`

## Docker Preview

- Jekyll の build から serve まで Docker で完結させたい場合は `compose.yaml` を使う
- 起動:

```bash
docker compose up site
```

- 公開 URL:

```text
http://127.0.0.1:4000
```

- compose は生成先を `_site-local` に固定する
- ポート公開は `127.0.0.1` に限定し、ローカル確認専用とする

- 静的ビルドだけ確認したい場合:

```bash
docker run --rm -u 1000:1000 -v "$PWD:/app" -w /app ruby:3.3 bash -lc "./bin/setup-site && ./bin/build-site -d _site-local"
```

## Playwright CLI Verification

- このセクションは、この PC に Playwright CLI と browser が導入済みである前提の運用メモ

- Docker でサイトを起動した状態でトップページを開く

```bash
playwright-cli -s=docs-check open http://127.0.0.1:4000
```

- トップページのフルページスクリーンショットを保存する

```bash
playwright-cli -s=docs-check screenshot --filename .playwright-cli/docs-check-home.png --full-page
```

- 代表ページへ移動して確認する

```bash
playwright-cli -s=docs-check goto http://127.0.0.1:4000/docs/03-WINDOWS-DEVELOPMENT-SETUP/
```

- 代表ページのフルページスクリーンショットを保存する

```bash
playwright-cli -s=docs-check screenshot --filename .playwright-cli/docs-check-dev-setup.png --full-page
```

- 終了後はブラウザセッションを閉じる

```bash
playwright-cli -s=docs-check close
```
