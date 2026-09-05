---
title: 02. 日本語入力と Windows 設定
permalink: /docs/02-WINDOWS-SETUP/
nav_order: 20
nav_label: 02. 日本語入力と Windows 設定
nav_section: setup
---

# 02. 日本語入力と Windows 設定

日本語表示と入力の癖、Explorer、OneDrive を復旧します。プリインストールアプリの一括削除は行いません。

## 完了条件

- 表示言語、国または地域、地域形式、システムロケール、キーボードが日本語である。
- `無変換 = IME オフ`、`変換 = IME オン`、`Ctrl + Space = 割り当てなし`になっている。
- Explorer に拡張子と隠しファイルが表示される。
- OneDrive は未サインイン、フォルダーバックアップ無効、自動起動無効で、アプリ自体は残っている。
- Known Folder の実パスが `C:\Users\kou` の直下から移動していない。

## 1. 日本語設定

設定 → 時刻と言語 → 言語と地域 で次を確認します。

- Windows の表示言語: 日本語
- 国または地域: 日本
- 地域形式: 日本語（日本）
- 優先する言語の先頭: 日本語
- 日本語のキーボード: Microsoft IME

設定検索で「管理用の言語の設定」を開き、「システム ロケールの変更」で日本語（日本）を選びます。変更した場合は再起動します。

## 2. Microsoft IME のキー設定

設定 → 時刻と言語 → 言語と地域 → 日本語 → 言語のオプション → Microsoft IME → キーボード オプション → キーとタッチのカスタマイズ を開きます。「キーの割り当て」を有効にし、次の値へ合わせます。

| キー | 動作 |
| --- | --- |
| 無変換 | IME オフ |
| 変換 | IME オン |
| Ctrl + Space | なし（割り当てない） |

メモ帳で日本語入力を開き、各キーの実挙動を確認します。IME 設定は安定した公開自動化インターフェースがないため、画面と実入力を正本にします。

## 3. Explorer

Explorer → 表示 → 表示 で「ファイル名拡張子」と「隠しファイル」を有効にします。アドレスバーへ `%USERPROFILE%` を入力し、`Desktop`、`Documents`、`Downloads`、`Pictures` が英語名の実フォルダーとして存在することも確認します。

## 4. OneDrive を使わない状態にする

Windows や Microsoft アカウントの案内で、OneDrive のサインイン、Windows Backup の復元、フォルダーバックアップを開始しません。

すでに OneDrive が関連付いている場合:

1. 通知領域の OneDrive → ヘルプと設定 → 設定 → アカウント を開く。
2. 「この PC のリンク解除」を実行する。
3. 同期とバックアップ → バックアップを管理 で Desktop、Documents、Pictures がすべてオフであることを確認する。
4. 設定 → アプリ → スタートアップ で Microsoft OneDrive をオフにする。
5. OneDrive を終了する。アプリのアンインストールはしない。

フォルダーバックアップを停止すると既存ファイルの場所を選ぶ画面が出る場合があります。実ファイルを `C:\Users\kou\Desktop`、`Documents`、`Pictures` に戻したうえで、次のパス確認を行います。クラウド側だけにあるファイルの移動はこのガイドでは自動化しません。

```powershell
[Environment]::GetFolderPath('Desktop')
[Environment]::GetFolderPath('MyDocuments')
[Environment]::GetFolderPath('MyPictures')
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders').'{374DE290-123F-4565-9164-39C4925E467B}'
Get-CimInstance Win32_StartupCommand | Where-Object Name -Match OneDrive
Get-Process OneDrive -ErrorAction SilentlyContinue
```

最初の4行が `C:\Users\kou` 直下を指し、再サインイン後に後半2つが何も返さないことを確認します。OneDrive のリンク解除は [Microsoft の公式手順](https://support.microsoft.com/en-US/onedrive/how-to-remove-an-account-in-onedrive)、フォルダーバックアップは [バックアップ管理](https://support.microsoft.com/en-US/onedrive/back-up-your-folders-with-onedrive) を参照します。

## 次に読む

[03. Windows アプリ・WSL・Docker]({{ '/docs/03-WINDOWS-DEVELOPMENT-SETUP/' | relative_url }}) に進みます。
