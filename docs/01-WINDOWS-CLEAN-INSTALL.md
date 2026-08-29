---
title: 01. Windows 11 とユーザープロファイル
permalink: /docs/01-WINDOWS-CLEAN-INSTALL/
nav_order: 10
nav_label: 01. Windows 11 とユーザー
nav_section: setup
---

# 01. Windows 11 と `C:\Users\kou`

最新安定版の日本語 Windows 11 を入れ、サポートされたアカウント操作でプロファイル名を固定します。Windows Insider のビルドは使いません。

## 完了条件

- 日本語版 Windows 11 の Windows Update が完了している。
- 管理者ユーザー `kou` でサインインでき、`$env:USERPROFILE` が `C:\Users\kou` である。
- Desktop、Documents、Downloads の実パスが `C:\Users\kou` の直下にある。
- 一時ユーザーは `kou` の動作確認後に整理されている。

## 1. 日本語版インストールメディアを作る

[Microsoft の Windows 11 ダウンロード](https://www.microsoft.com/software-download/windows11) からメディア作成ツールを取得し、言語に日本語を選びます。日本語表示の Explorer でも、Known Folder の既定の実パスは `%USERPROFILE%\Documents`、`Desktop` などです。表示名の「ドキュメント」と実フォルダー名は別物なので、日本語版で問題ありません。

USB から起動し、最新安定版を通常どおりクリーンインストールします。Insider の ISO やプレビューチャネルは選びません。

## 2. 通常の OOBE を一時ユーザーで完了する

ネットワークを接続し、画面の案内どおり OOBE を完了します。Home / Pro の画面差を避けるため、非公式の OOBE bypass は使いません。

ここで作るユーザーは環境構築用の一時管理者です。Microsoft アカウントが必須なら普段使うアカウントで進めて構いませんが、この一時プロファイルへファイルを保存しません。OneDrive や Windows Backup の復元・フォルダーバックアップは開始しません。

## 3. ローカル管理者 `kou` を作る

1. 設定 → アカウント → その他のユーザー を開く。
2. 「アカウントの追加」→「このユーザーのサインイン情報がありません」→「Microsoft アカウントを持たないユーザーを追加する」を選ぶ。
3. ユーザー名を `kou` にしてローカルアカウントを作る。
4. 作成したユーザーの「アカウントの種類の変更」で「管理者」を選ぶ。
5. 一時ユーザーからサインアウトし、`kou` へ初回サインインする。

[Microsoft のユーザーアカウント管理](https://support.microsoft.com/windows/security/identity-signin/manage-user-accounts-in-windows) にある「その他のユーザー」の操作だけを使います。

## 4. パスと管理者権限を確認する

`kou` の PowerShell で実行します。

```powershell
$env:USERPROFILE
[Environment]::GetFolderPath('Desktop')
[Environment]::GetFolderPath('MyDocuments')
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders').'{374DE290-123F-4565-9164-39C4925E467B}'
```

順に `C:\Users\kou`、`C:\Users\kou\Desktop`、`C:\Users\kou\Documents`、`%USERPROFILE%\Downloads` 相当であることを確認します。管理者として PowerShell を開けることも確認します。

## 5. 一時ユーザーを整理し、Microsoft アカウントへ切り替える

`kou` への再サインイン、パス、管理者権限がすべて正しいことを確認してから、一時ユーザーを設定 → アカウント → その他のユーザー で削除します。削除は自動化しません。

続いて `kou` で設定 → アカウント → ユーザーの情報 を開き、「Microsoft アカウントでのサインインに切り替える」を選びます。切り替え後も `$env:USERPROFILE` が変わっていないことを再確認します。

## 6. Windows Update

設定 → Windows Update で更新と再起動を、更新がなくなるまで繰り返します。設定 → Windows Update → Windows Insider Program では参加していない状態を維持します。

## 次に読む

[02. 日本語入力と Windows 設定]({{ '/docs/02-WINDOWS-SETUP/' | relative_url }}) に進みます。
