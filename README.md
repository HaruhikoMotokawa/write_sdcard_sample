# Write SDCard Sample

Flutterを使用したSDカードやデバイスストレージへのファイル読み書きをデモンストレーションするサンプルアプリケーションです。

詳細は以下の記事でも解説しています。

https://zenn.dev/harx/articles/b1113411780378

## 概要

このプロジェクトでは以下の3つの異なるアプローチでファイルシステムへのアクセスを実装しています：

1. **Path Provider** - `path_provider` パッケージを使用して、デバイスのディレクトリパスを取得し、ファイル操作を行う方法
2. **DocMan** - `docman` パッケージを使用して、ドキュメントの読み書き操作を行う方法
3. **File Picker** - `file_picker` パッケージを使用して、ファイル/ディレクトリ選択から読み書き操作を行う方法

## 始め方

1. リポジトリをクローンする：
   ```
   git clone <repository-url>
   cd write_sdcard_sample
   ```

2. 依存関係をインストールする：
   ```
   flutter pub get
   ```

3. 自動生成コードを生成する：
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   または
   ```
   derry build
   ```

4. アプリを実行する：
   ```
   flutter run
   ```

## 注意事項

- Androidデバイス限定です
- path_providerを使ったデータ保存はデバイス差し込み式のSDカード対応機種のみ対応であり、USBストレージへの保存は対応していません

## ディレクトリ構造

```
lib/
  ├── main.dart            # アプリケーションのエントリーポイント
  ├── router/              # 画面遷移の設定
  │   └── router.dart
  ├── screen/              # 各機能の画面実装
  │   ├── doc_man/         # DocMan による実装
  │   ├── file_picker/     # File Picker による実装
  │   ├── home/            # ホーム画面
  │   └── path_provider/   # Path Provider による実装
  └── shared/              # 共通コンポーネント
      └── app_dialog.dart  # ダイアログコンポーネント
```
