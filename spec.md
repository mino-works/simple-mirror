# 鏡(かがみ) — アプリ仕様書

## 概要

| 項目 | 内容 |
|---|---|
| アプリ名（表示） | 鏡(かがみ) -スマートミラー＆デイリー- Mirror |
| Bundle ID | `com.minoapp.fortunemirror` |
| 対応OS | iOS 15.0+ |
| 言語 | 日本語・英語（端末設定に追従） |
| カテゴリ | ユーティリティ（プライマリ）／ライフスタイル |

フロントカメラをリアルタイム鏡として使い、毎日のデイリーメッセージ（占い）を届けるスマートミラーアプリ。
ウサギキャラクターの着せ替えと育成要素が継続利用を促す。

---

## 画面構成

```
MirrorScreen（ホーム）
├── MenuDrawer（左スワイプ or ハンバーガー）
│   ├── プレミアムプラン購入・復元
│   ├── 言語切替（日本語 / English）
│   ├── 利用規約
│   └── プライバシーポリシー
├── FortuneResultScreen（占い結果）
│   └── CostumeScreen（着せ替え、結果画面からも遷移可）
└── CostumeScreen（着せ替え、ミラー画面右上アイコンから）
```

---

## 画面仕様

### 1. MirrorScreen（鏡画面）

アプリのメイン画面。全画面カメラプレビューにUIを重ねて表示する。

**レイアウト（Stack構造）:**
- 全画面カメラプレビュー（背景）
- 左上: ハンバーガーボタン → MenuDrawer を開く
- 上部中央〜右: 明るさスライダー（露出調整）
- 左上（ハンバーガー下）: 朝活タイマー（⏱ MM:SS 表示）
- 右上:
  - 吹き出し（メッセージ状態テキスト）
  - メッセージアイコン（タップで FortuneResultScreen へ）
  - 着せ替えアイコン（タップで CostumeScreen へ）
- 下部: ズームスライダー + ミラー切替トグル（ミラー / 他人から）

**メッセージフロー:**
1. アプリ起動 → カメラ初期化と同時に `_startFortuneFlow()` を呼び出す
2. `fortuneProvider`・`fortuneCountProvider`・`progressProvider` の初期化完了を待機（`Future.wait`）
3. 既に今日の結果がある → 吹き出しを「メッセージ届いた！」で即表示
4. 初回 → 吹き出しを「メッセージを準備中...」で表示 → 3秒待機 → 生成 → 「メッセージ届いた！」に切替
5. 占いアイコン / 吹き出しタップ → `FortuneResultScreen` へ遷移
6. 結果画面で「もう一度」（プレミアムのみ）→ `'redivine'` を pop result として返す → `clearFortune()` + フロー再実行

**カメラ:**
- フロントカメラ使用。ResolutionPreset.veryHigh
- 結果画面・着せ替え画面への遷移時に `pausePreview()` / 戻り時に `resumePreview()`
- カメラ権限拒否時でも占いフローは動作する（カメラなしでも起動可）

**ミラー切替:**
- 「ミラー」モード: 通常表示（左右反転なし）
- 「他人から」モード: `Transform.scale(scaleX: -1)` で左右反転

---

### 2. FortuneResultScreen（占い結果画面）

**構成（上から）:**
1. ウサギヒーロー画像エリア（画面高さの55%）
   - 背景画像 + 結果に応じたウサギ画像（着せ替え適用済み）
2. タイトルプレート（グラデーション帯、ヒーローと白背景の境界に重ねる）
3. 白背景エリア:
   - カード3枚横並び（ときめき / エネルギー / 集中力、絵文字＋キーワード表示）
   - ウサギからのひとことカード（dailyMessage）
   - ボタンエリア（プレミアム / 非プレミアムで切替）
   - ナビゲーションボタン（鏡に戻る / きせかえ）

**ボタンエリア:**
- プレミアムユーザ: 「もう一度占う」ボタン → `Navigator.pop('redivine')`
- 非プレミアムユーザ: 「もっと占う」アップグレードボタン + サブスクリプション説明テキスト + 利用規約・プライバシーリンク

**副作用（initState）:**
- `progressProvider.recordFortuneView()` を呼び出し → 本日の累計日数を記録
- `overallLuck >= 80` の場合 → App Review ダイアログをリクエスト

---

### 3. CostumeScreen（着せ替え画面）

**構成:**
- 2列グリッド（GridView）
- 解放済みコスチューム: タップで選択（選択中は金枠 + チェックマーク）
- ロック中コスチューム: グレースケール表示 + 「あとN日」テキスト
- Coming soon カード: 5枚（固定）
- 戻るボタン

---

### 4. MenuDrawer（メニュー）

**構成:**
- アプリ名ヘッダー
- プレミアムセクション:
  - 加入済み: バッジ表示のみ
  - 未加入: 購入ボタン（価格・月額表示）+ 復元リンク + エラーメッセージ（必要時）
- 言語セクション: 日本語 / English ラジオ選択
- サポートセクション: 利用規約 / プライバシーポリシー

---

## 機能要件

### 占い（デイリーメッセージ）

- 1日1回生成・保存（当日キーで SharedPreferences に JSON 保存）
- 生成ロジック: `FortuneGenerator.generateFortune()` でランダム生成（ローカル、APIなし）
- 結果は `yyyy-MM-dd` キーで保存。翌日になると自動的に「未占い」扱いになる

**データ構造（Fortune モデル）:**
```dart
class Fortune {
  final int overallLuck;    // 0〜100
  final int workLuck;       // 0〜100
  final int loveLuck;       // 0〜100
  final int moneyLuck;      // 0〜100
  final String overallTitle;    // タイトルテキスト（日本語）
  final String overallComment;  // 総合コメント
  final String workComment;
  final String loveComment;
  final String moneyComment;
  final String dailyMessage;    // ウサギのひとこと
  final HamsterExpression expression;  // normal/smile/sparkle/cheer/worry/proud
  final String imagePath;       // ウサギ画像パス
  final String? backgroundPath; // 背景画像パス（nullの場合はウサギ画像に背景込み）
}
```

### 占い回数制限

- 無料ユーザ: 1日1回
- プレミアムユーザ: 無制限（「もう一度占う」で `clearFortune()` → 再生成フロー）
- `fortuneCountProvider` が当日の占い実施済みフラグを管理

### 朝活タイマー

- アプリ起動と同時に自動スタート
- 結果画面・着せ替え画面へ遷移時に一時停止 → 戻り時に再開
- 日付が変わると翌日分としてリセット
- 鏡画面左上に `⏱ MM:SS` 形式で常時表示
- SharedPreferences に当日の累計秒数を保存（キー: `routine_date`, `routine_seconds`）

### 着せ替え（コスチューム）

| コスチューム | アンロック条件 |
|---|---|
| ノーマル | 最初から |
| 人参コスプレ | 累計占い確認日数 3日以上 |
| ドレス | 累計占い確認日数 7日以上 |
| ヒップホップ | 累計占い確認日数 14日以上 |

- アンロック判定: `progress.totalDays >= costume.unlockDays`
- 着せ替えは占い結果画面のウサギ画像にも反映（`costume.applyTo(fortune.imagePath)` でパス変換）
- 選択中コスチュームは `costumeProvider`（SharedPreferences 永続化）

### 累計日数カウント（progressProvider）

- 占い結果画面を開いた際に `recordFortuneView()` を呼び出す
- 当日の日付キーが未登録の場合のみ記録（1日1回）
- SharedPreferences に `yyyy-MM-dd` 形式の文字列の Set として保存（キー: `login_days`）

### 多言語対応

- 日本語 / 英語をサポート
- 端末設定に追従、アプリ内で手動切替も可能（MenuDrawer）
- 設定は SharedPreferences に保存
- 起動時に locale を事前読込み（locale フラッシュ防止）

### IAP（サブスクリプション）

- プロダクトID: `com.minoapp.fortunemirror.premium_monthly`
- プラン名: 無制限プラン / Unlimited Plan
- 月額（価格はプロダクト情報から動的取得）
- 購入・復元・エラーハンドリングは `iapProvider` が担当

---

## データ永続化（SharedPreferences）

| キー | 型 | 内容 |
|---|---|---|
| `yyyy-MM-dd`（当日） | String (JSON) | 当日の占い結果 |
| `fortune_count_today` | int | 当日の占い回数 |
| `fortune_count_date` | String | 占い回数記録の対象日 |
| `login_days` | StringList | 累計占い確認日の日付一覧 |
| `selected_costume` | String | 選択中コスチューム名 |
| `locale` | String | 言語設定（`ja` / `en`） |
| `premium` | bool | プレミアム加入状態 |

---

## 状態管理（Riverpod）

| Provider | State | 役割 |
|---|---|---|
| `fortuneProvider` | `Fortune?` | 当日の占い結果 |
| `fortuneCountProvider` | `FortuneCountState` | 当日の占い回数 |
| `progressProvider` | `ProgressState` | 累計占い確認日数 |
| `costumeProvider` | `Costume` | 選択中コスチューム |
| `iapProvider` | `IapState` | IAP状態（購入済み・価格・ローディング） |
| `localeProvider` | `Locale` | 言語設定 |

全 Provider が `StateNotifierProvider`。起動時の初期化順序の競合は `Completer<void> initialized` パターンで解決。

---

## アセット構成

```
assets/
├── images/
│   ├── fortune.png              # 占いアイコン（右上）
│   ├── rabbit_small.png         # ひとことカードのウサギアイコン
│   ├── icons/
│   │   ├── icon_love.png
│   │   ├── icon_money.png
│   │   └── icon_work.png
│   └── rabbits/
│       ├── default/             # ノーマルコスチューム
│       │   ├── rabbit_normal.png
│       │   ├── rabbit_good.png
│       │   ├── rabbit_bad.png
│       │   ├── rabbit_star.png  # 着せ替え選択画面プレビュー
│       │   └── ...（表情別）
│       ├── carrot/              # 人参コスプレ（3日〜）
│       ├── dress/               # ドレス（7日〜）
│       └── hiphop/              # ヒップホップ（14日〜）
```

ウサギ画像のファイル名は Fortune.imagePath（`rabbit_good.png` 等）と対応。
着せ替え時は `costume.applyTo(imagePath)` でディレクトリを差し替えて同名ファイルを参照する。

---

## 主要ライブラリ

| パッケージ | バージョン | 用途 |
|---|---|---|
| `flutter_riverpod` | - | 状態管理 |
| `camera` | ^0.11.0+1 | フロントカメラ |
| `in_app_purchase` | ^3.2.0 | IAP |
| `shared_preferences` | - | 永続化 |
| `permission_handler` | - | カメラ権限 |
| `url_launcher` | - | 外部リンク（法的情報） |

---

## ビジネスロジック

### 無料 vs プレミアムの差分

| 機能 | 無料 | プレミアム |
|---|---|---|
| 占い | 1日1回 | 無制限（何度でも再占い可） |
| 着せ替え | 同じ | 同じ |
| 広告 | なし | なし |

### App Review リクエスト

以下のタイミングで `ReviewHelper.requestForFortune/Costume()` を呼び出す:
- 占い結果 `overallLuck >= 80` のとき（結果画面 initState）
- 着せ替え画面を開いたとき、ノーマル以外のコスチュームがアンロック済みの場合

---

## デバッグ機能（コメントアウト中）

リリース時はすべてコメントアウト。削除しない。

- `MirrorScreen`: デバッグボタン（TESTボタン）、占いシート選択、累計日数操作ボタン
- `ProgressNotifier`: `debugAddDays(int n)`、`debugResetDays()`
