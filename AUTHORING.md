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
