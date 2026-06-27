---
title: 06. シェル初期化設定
permalink: /docs/06-SHELL-CONFIG/
nav_order: 60
nav_label: 06. シェル初期化設定
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
- `open` 関数が `.bashrc` に含まれている（WSL / Git Bash 両対応）
- `wopen` 関数が `.bashrc` に含まれている（WSL / Git Bash 両対応）

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

# ---------------------
# open (Windows 側でファイル/フォルダを開く。WSL / Git Bash 両対応)
#   ディレクトリ      -> エクスプローラで開く
#   .html / .htm      -> 既定ブラウザで開く (関連付け経由)
#   その他のファイル  -> エクスプローラでそのファイルを選択表示
#   入力は Linux / Windows どちらのパス形式でも受け付ける
#   実行環境（WSL / Git Bash）は関数内で判定し wslpath / cygpath を切り替える
# ---------------------
open() {
  local input="${1:-.}"
  local tool lpath winpath rc

  # 実行環境を判定して変換ツールを選ぶ（wslpath / cygpath は -u/-w/-- 互換）
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) tool=cygpath ;;
    *)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        tool=wslpath
      else
        echo "open: WSL / Git Bash 以外は未対応です" >&2
        return 1
      fi
      ;;
  esac

  # 入力が Windows 形式なら Linux パスへ正規化する（以降の解決は Linux パスで行う）。
  #   C:\... / C:/...（ドライブ） / \\...（UNC） / バックスラッシュを含む -> Windows 形式
  # -- で input をオプションと解釈させない（先頭 '-' のファイル名対策）
  case "$input" in
    [A-Za-z]:[\\/]* | *\\*)
      lpath="$("$tool" -u -- "$input")"; rc=$?
      if [ "$rc" -ne 0 ] || [ -z "$lpath" ]; then
        echo "open: cannot normalize path -> $input" >&2
        return 1
      fi
      ;;
    *)
      lpath="$input"
      ;;
  esac

  if [ ! -e "$lpath" ]; then
    echo "open: not found -> $lpath" >&2
    return 1
  fi

  # 開くために Linux パスを Windows パスへ変換する
  winpath="$("$tool" -w -- "$lpath")"; rc=$?
  if [ "$rc" -ne 0 ] || [ -z "$winpath" ]; then
    echo "open: cannot convert path -> $lpath" >&2
    return 1
  fi

  if [ -d "$lpath" ]; then
    explorer.exe "$winpath"
  elif [[ "${lpath,,}" == *.html || "${lpath,,}" == *.htm ]]; then
    explorer.exe "$winpath"
  else
    # Git Bash では先頭 / の引数が Windows パスへ変換されるのを防ぐ
    MSYS2_ARG_CONV_EXCL='*' explorer.exe /select,"$winpath"
  fi

  # explorer.exe は成功時も非0を返すため、戻り値を正常に揃える
  return 0
}

# ---------------------
# wopen (対象の場所を Windows のエクスプローラで開く。WSL / Git Bash 両対応)
#   ファイル      -> 含まれるフォルダを開き、そのファイルを選択表示する
#   ディレクトリ  -> そのフォルダを開く
#   入力は open と同じ Linux / Windows パスに加え file:// URL も受け付ける
#     file://wsl.localhost/<distro>/...（WSL） / file:///C:/...（Windows ドライブ）
#   用途: ファイル共有のため、対象の場所をエクスプローラで開く
#   実行環境（WSL / Git Bash）は関数内で判定し wslpath / cygpath を切り替える
# ---------------------
wopen() {
  local input="${1:-.}"
  local tool rest win lpath winpath rc

  # 実行環境を判定して変換ツールを選ぶ（wslpath / cygpath は -u/-w/-- 互換）
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) tool=cygpath ;;
    *)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        tool=wslpath
      else
        echo "wopen: WSL / Git Bash 以外は未対応です" >&2
        return 1
      fi
      ;;
  esac

  # 入力を Linux パスへ正規化する（以降の解決・存在確認は Linux パスで行う）
  case "$input" in
    file://*)
      # file:// URL。スキームを外し percent-encoding を復号する
      rest="${input#file://}"
      # %XX（2桁hex）だけを復号する。%XX でない % と入力中の \ はそのまま扱う
      rest="$(printf '%s' "$rest" | sed -e 's/\\/\\\\/g' -e 's/%\([0-9A-Fa-f]\{2\}\)/\\x\1/g')"
      rest="$(printf '%b' "$rest")"
      case "$rest" in
        /[A-Za-z]:*)  # file:///C:/... : ドライブ形式。先頭 / を外して Windows パスへ変換する
          win="${rest#/}"
          lpath="$("$tool" -u -- "$win")"; rc=$?
          ;;
        /*)           # file:///path : すでに Linux 絶対パス
          lpath="$rest"; rc=0
          ;;
        *)            # file://host/... : UNC 形式。先頭に // を補って変換する
          lpath="$("$tool" -u -- "//$rest")"; rc=$?
          ;;
      esac
      if [ "$rc" -ne 0 ] || [ -z "$lpath" ]; then
        echo "wopen: cannot resolve url -> $input" >&2
        return 1
      fi
      ;;
    [A-Za-z]:[\\/]* | *\\*)  # Windows 形式（ドライブ / UNC / バックスラッシュを含む）
      lpath="$("$tool" -u -- "$input")"; rc=$?
      if [ "$rc" -ne 0 ] || [ -z "$lpath" ]; then
        echo "wopen: cannot normalize path -> $input" >&2
        return 1
      fi
      ;;
    *)  # Linux パス（相対含む）
      lpath="$input"
      ;;
  esac

  if [ ! -e "$lpath" ]; then
    echo "wopen: not found -> $lpath" >&2
    return 1
  fi

  # 開くために Linux パスを Windows パスへ変換する
  winpath="$("$tool" -w -- "$lpath")"; rc=$?
  if [ "$rc" -ne 0 ] || [ -z "$winpath" ]; then
    echo "wopen: cannot convert path -> $lpath" >&2
    return 1
  fi

  if [ -d "$lpath" ]; then
    explorer.exe "$winpath"
  else
    # Git Bash では先頭 / の引数が Windows パスへ変換されるのを防ぐ
    MSYS2_ARG_CONV_EXCL='*' explorer.exe /select,"$winpath"
  fi

  # explorer.exe は成功時も非0を返すため、戻り値を正常に揃える
  return 0
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

### open の注意事項

- WSL（Ubuntu）と Git Bash（Windows）の両方で動作する。実行環境を関数内で判定し、パス変換に WSL では `wslpath`、Git Bash では `cygpath` を使い分ける（どちらも標準同梱で追加パッケージは不要）
- 入力は Linux 形式（`/home/...`）でも Windows 形式（`C:\...`, `C:/...`, `\\...`）でも受け付ける。Windows 形式は先頭で Linux パスへ正規化してから存在確認・種別判定を行う
- ファイルは実行しない。`.html` / `.htm` だけを関連付け（既定ブラウザ）で開き、フォルダは Explorer で開き、その他のファイルは Explorer で選択表示するだけにとどめる
- WSL / Git Bash 以外の環境では、`open` 実行時に「未対応」と表示して何もしない

### wopen の注意事項

- 常に Explorer で開く。ファイルを渡すと、そのファイルを含むフォルダを開いてファイルを選択表示し、ディレクトリを渡すとそのフォルダを開く。`open` と異なりブラウザは起動しない（`.html` も Explorer で選択表示する）
- ファイル共有のため「対象の場所をエクスプローラで開く」用途に使う
- `open` と同じ Linux 形式・Windows 形式のパスに加え、`file://` URL を受け付ける。ブラウザのアドレスバーに出る `file://wsl.localhost/<distro>/...`（WSL）や `file:///C:/...`（Windows）をそのまま渡せる
- `file://` URL の空白等は percent-encoding（`%20` など）で渡されるため、`%XX`（2桁 hex）形式を内部で復号してから解決する
- 信頼できないホストの `file://` URL（`file://<外部ホスト>/...`）は開かない。ホスト部が UNC（`\\host\...`）として解決され、Windows がそのホストへ接続・認証（資格情報の送出）を試みうる
- WSL / Git Bash 以外の環境では、`wopen` 実行時に「未対応」と表示して何もしない
