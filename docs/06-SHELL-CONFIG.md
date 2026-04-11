---
title: 06. シェル初期化設定
permalink: /docs/06-SHELL-CONFIG/
---

# 06. シェル初期化設定

Git Bash（Windows）と Ubuntu（WSL）で共通のシェル初期化ファイルを構成する手順。

## 前提

- Git Bash または Ubuntu のターミナルが利用可能である

## このドキュメントの完了条件

- `.bash_profile` が `.bashrc` を読み込む構成になっている
- `.bashrc` にヒストリ設定、エディタ設定、エイリアスが入っている
- fnm の初期化が `.bashrc` に含まれている（fnm インストール済みの場合）
- grb 関数が `.bashrc` に含まれている

## 1. .bash\_profile

ログインシェルと非ログインシェルの両方で `.bashrc` が読まれるようにする。

```sh
cat > ~/.bash_profile <<'EOF'
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF
```

| シェル起動パターン | 読まれるファイル |
| --- | --- |
| ログインシェル（Git Bash, WSL Ubuntu, ssh） | `.bash_profile` のみ |
| 非ログインシェル（tmux, サブシェル） | `.bashrc` のみ |

`.bash_profile` から `.bashrc` を source することで、どちらのパターンでも同じ設定が適用される。

> WSL の Ubuntu ターミナルはデフォルトでログインシェルとして起動される。

## 2. .bashrc

Ubuntu にはデフォルトの `.bashrc` があるため、先にバックアップを取る。Git Bash（Windows）では不要。

```sh
[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak
```

以下のコマンドで `.bashrc` を作成する。

```sh
cat > ~/.bashrc <<'BASHRC'
# 非対話シェルでは読み込まない
case $- in
  *i*) ;;
    *) return;;
esac

# ---------------------
# ヒストリ
# ---------------------
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# ---------------------
# シェルオプション
# ---------------------
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

# ---------------------
# エディタ
# ---------------------
export EDITOR=vim
export VISUAL=vim

# ---------------------
# 色付き出力
# ---------------------
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# ---------------------
# エイリアス
# ---------------------
alias ll='ls -alF'
alias la='ls -A'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline -20'

# ---------------------
# プロンプト
# ---------------------
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

# ---------------------
# fnm (Node.js バージョン管理)
# ---------------------
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd --shell bash)"
fi

# ---------------------
# grb (マージ済みブランチ削除)
# ---------------------
grb() {
  git switch main && git pull origin main && git branch --merged main | grep -v "^[* ]*main$" | xargs -r git branch -d
}
BASHRC
```

### 設定項目の説明

| 設定 | 効果 |
| --- | --- |
| `case $- in *i*) ...` | 非対話シェル（スクリプト実行等）では `.bashrc` を読み込まない |
| `HISTSIZE=10000` | メモリ上に保持するコマンド履歴の件数 |
| `HISTFILESIZE=20000` | `.bash_history` ファイルに保存する最大行数 |
| `HISTCONTROL=ignoreboth:erasedups` | スペース先頭のコマンドと重複を履歴から除外する |
| `shopt -s histappend` | シェル終了時に履歴を上書きではなく追記する |
| `shopt -s checkwinsize` | ウィンドウサイズ変更時に `LINES` と `COLUMNS` を更新する |
| `shopt -s globstar` | `**` で再帰的にディレクトリを展開できるようにする |
| `EDITOR` / `VISUAL` | コマンドラインツールが使うデフォルトエディタ |

### エイリアスの説明

| エイリアス | 展開 | 用途 |
| --- | --- | --- |
| `ll` | `ls -alF` | 詳細一覧表示 |
| `la` | `ls -A` | 隠しファイル含む一覧 |
| `gs` | `git status -sb` | Git ステータスの短縮表示 |
| `gd` | `git diff` | Git の差分表示 |
| `gl` | `git log --oneline -20` | 直近 20 コミットの一行表示 |

### grb の注意事項

- 既定ブランチが `main` ではないリポジトリでは動作しない
- `git branch --merged main` はローカルブランチのみを対象とする
- 対話シェルの初期化に依存するため、Codex CLI のように `.bashrc` を読まない環境では使えない。その場合は `git rb`（[05. 開発ツール共通設定]({{ '/docs/05-DEV-TOOL-CONFIG/' | relative_url }}) で設定済み）を使う

### fnm の初期化

`command -v fnm` で fnm がインストール済みかを確認してから初期化する。これにより、fnm 未インストールの環境（Windows Git Bash 等）でもエラーにならない。
