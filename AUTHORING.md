# Site Authoring Guide

このファイルはサイト運用者向けの正本です。利用者向けセットアップは `index.md` から始めます。

## ローカル確認

Ruby / Bundler がある環境では次を実行します。依存は `vendor/bundle` に閉じます。

```bash
./bin/setup-site
./bin/build-site
./bin/serve-site
```

公開先は `http://127.0.0.1:4000` です。Ruby をホストへ入れない場合は `docker compose up site` を使います。Compose のポートは localhost だけへ公開し、生成先は `_site-local` に分離しています。

## Theme Contract

- 公開ページには front matter を付ける。
- `nav_section` は必須手順なら `setup`、補足なら `reference` にする。
- ナビ順の正本は `nav_order`、表示名は `nav_label` とする。
- ナビに出さないページは `nav_hidden: true` とする。
- 既存の `/docs/.../` permalink は維持し、本文リンクは `relative_url` を使う。
- 共通フレームは `_layouts/default.html`、ナビ描画は `_includes/site-nav-links.html`、見た目は `assets/css/style.scss` が担う。

## 表示確認

サイトを起動した状態で、グローバル `playwright-cli` を使います。リポジトリには CLI が生成する skill やブラウザープロファイルを保存しません。

```bash
playwright-cli -s=docs-check open http://127.0.0.1:4000
playwright-cli -s=docs-check resize 1440 900
playwright-cli -s=docs-check screenshot --filename .playwright-cli/docs-desktop.png --full-page
playwright-cli -s=docs-check resize 390 844
playwright-cli -s=docs-check screenshot --filename .playwright-cli/docs-mobile.png --full-page
playwright-cli -s=docs-check close
```

トップ、Windows 設定、WSL 設定、AI ツール、リファレンスの代表ページで、必須手順とリファレンスの区別、コードブロック、表、前後リンクを確認します。

## 変更時の検証

```bash
./bin/build-site
bash -n scripts/wsl/*.sh
```

加えて、PowerShell スクリプトの構文、生成 HTML の内部リンク、対象外ツールや古い導入コマンドが復活していないことを確認します。Windows / WSL の導入スクリプトは実機を変更するため、通常のサイト確認では dry-run までに留めます。
