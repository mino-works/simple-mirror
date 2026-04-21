# ミラー占い (Mirror Fortune) - Claude Code Context

## プロジェクト概要
iOSのカメラミラー＋占いアプリ。フロントカメラをリアルタイム鏡として使用し、毎日占い結果を表示する。ウサギキャラクターの着せ替え機能付き。

- Bundle ID: `com.minoapp.fortunemirror`
- 対応OS: iOS 15.0+
- 言語: 日本語・英語

## よく使うコマンド

```bash
# ビルド確認
flutter build ios --no-codesign

# App Store用IPA作成
flutter build ipa

# TestFlight/App Storeアップロード
xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios -u "minokohei@gmail.com" -p "<app-specific-password>"

# 実機確認
flutter run
```

## アーキテクチャ

- **状態管理**: Riverpod (StateNotifierProvider)
- **永続化**: SharedPreferences
- **IAP**: in_app_purchase ^3.2.0
- **カメラ**: camera ^0.11.0+1

## 主要ファイル

| ファイル | 役割 |
|---|---|
| `lib/screens/mirror_screen.dart` | メイン画面（カメラ・占いフロー） |
| `lib/screens/fortune_result_screen.dart` | 占い結果画面 |
| `lib/screens/costume_screen.dart` | 着せ替え画面 |
| `lib/screens/menu_drawer.dart` | メニュー（IAP・言語・法的情報） |
| `lib/providers/iap_provider.dart` | App内課金ロジック |
| `lib/providers/fortune_provider.dart` | 占い結果の生成・保存 |
| `lib/providers/fortune_count_provider.dart` | 1日の占い回数管理 |
| `lib/providers/progress_provider.dart` | 累計ログイン日数（着せ替えアンロック） |
| `lib/providers/locale_provider.dart` | 言語設定 |
| `lib/l10n/app_localizations.dart` | 多言語文言 |

## IAP
- プロダクトID: `com.minoapp.fortunemirror.premium_monthly`
- プラン名: 無制限プラン / Unlimited Plan
- 非プレミアム: 1日1回占い制限
- プレミアム: 無制限（結果画面から「もう一度占う」で鏡に戻り再占い）

## 着せ替えアンロック条件
- ノーマル: 最初から
- 人参コスプレ: 累計7日占い結果を見る
- ドレス: 累計14日占い結果を見る

## デバッグ機能
mirror_screen.dart・progress_provider.dartにデバッグコードがコメントアウトで残っている。リリース時はコメントアウトのまま維持。

## バージョン管理ルール
- マイナーバージョン（0.1）単位で上げる（例: 2.1.0 → 2.2.0）
- ビルド番号は連番

## 注意事項
- GitHubはパブリックリポジトリのためAPIキー・パスワード等をコミットしない
- デバッグボタン・デバッグ関数はコメントアウトで残す（削除しない）
