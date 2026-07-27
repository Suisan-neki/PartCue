# PartCue アーキテクチャメモ

## 1. プロダクト境界

PartCueの単位は「1小節」ではなく「一つの入り」です。

一つのCueCardは次の2トラックを持ちます。

- CUE: 入る直前に聴く他パート
- YOU: 自分の入りと、その直後の短いフレーズ

MVPでは各トラックを4/4の1小節に制限しています。これは実装制約であり、長期的なプロダクト定義ではありません。

## 2. Model

`MusicModels.swift` が音楽上の意味を持つデータを管理します。

主な型は以下です。

- `CueCard`
- `TrackRole`
- `RehearsalMode`
- `NoteEvent`
- `Pitch`
- `NoteDuration`
- `Accidental`
- `PracticeAttempt`

画面上のX座標やY座標は保存しません。

表示時に次の変換を行います。

- `startBeat` → X座標
- `Pitch.staffOffset` → Y座標
- `NoteDuration` → 符頭、符幹、旗
- `playbackBeat` → 再生カーソル

## 3. ViewModel

`ScoreEditorViewModel` は現段階で以下を管理します。

### 編集状態

- 選択中のトラック
- 選択中の音価
- 臨時記号と付点
- CUEの現在入力拍
- YOUの現在入力拍
- 各トラックの音符イベント
- 入力可能性
- パート単位のUndo

### 練習状態

- Together / Cue Only / Rehearse
- 再生中か
- 再生位置
- 現在強調する音符
- 完了した練習回数
- インターミッションを提案するか
- 広告報酬による詳細フィードバック解放状態

現段階では編集と練習を一つのViewModelに置いています。マイク入力と試行履歴が追加された段階で、次へ分割します。

- `CueEditorViewModel`
- `RehearsalViewModel`

## 4. View

Viewは状態を表示し、ユーザー操作をViewModelへ渡します。

- `ScoreEditorView`: 2トラック編集画面
- `TrackStaffRow`: CUE / YOUのラベルと五線譜
- `StaffView`: Canvas描画とタップ座標変換
- `PlaybackView`: 3つの練習モード
- `IntermissionView`: 自然な区切りでの広告体験
- `DurationPaletteView`: 音価
- `ModifierPanelView`: 休符、臨時記号、付点、Undo、練習開始

## 5. Audio Service

`TonePlaybackEngine` はCUEとYOUを同一のPCMバッファへ描画します。

同一バッファを使う理由は、2トラック間の開始時刻をサンプル単位で揃えるためです。

現段階では聞き分けやすくするため、以下の差を付けています。

- CUE: 左寄り、3倍音を弱く追加
- YOU: 右寄り、2倍音を弱く追加

音色は本番品質ではありません。Cue関係の体験検証が目的です。

## 6. 広告境界

`AdExperienceService.swift` は広告SDKをUIから切り離す境界です。

広告体験には次の不変条件を置きます。

- 編集中に広告を出さない
- 再生中に広告を出さない
- Rehearse中に広告を出さない
- ミスの直後に広告を出さない
- 広告を自動表示しない
- 3回の練習セット後に一度だけ提案する
- 見ない選択を常に残す
- 広告報酬はアプリ内の非金銭的な機能とする

現在は`PreviewIntermissionAdService`相当のUIプレビューのみです。

本番では以下を接続します。

- AdMob Rewarded Ad
- RevenueCat AdMob adapter
- placement: `session_intermission_rewarded`
- AdMob Server-Side Verification
- RevenueCat verified reward

セッション終了後にはNative Adも検討します。

- placement: `session_summary_native`

## 7. 次の音声アーキテクチャ

入りの判定を実装するときは、現在の`Date`と30fpsの`Timer`を判定根拠に使いません。

予定された入りと実際の発音を、同一のオーディオサンプル時刻で比較します。

追加予定の責務は以下です。

### `EnsemblePlaybackEngine`

- 複数トラック同期再生
- 期待する入りのサンプル時刻
- 再生完了通知

### `OnsetDetector`

- マイクバッファ
- ノイズフロアの推定
- 急激な音量立ち上がりの検出
- 最初の発音サンプル時刻

### `AttemptEvaluator`

- 予定サンプルと実測サンプルの差
- ミリ秒変換
- Early / Late
- 将来の音高判定

## 8. 時間表現の移行

現在はMVPの理解しやすさを優先し、拍位置と音価を`Double`で管理しています。

マイク判定へ入る前に、内部時間を整数tickへ移行します。

初期案:

- 1四分音符 = 480 ticks
- 4/4の1小節 = 1920 ticks

これにより付点、連符、オーディオサンプル時刻への変換を一貫して扱えます。

## 9. 今回あえて簡略化した点

- 永続化なし
- Repositoryなし
- UseCase層なし
- DIコンテナなし
- マイク判定なし
- 広告SDK接続なし
- RevenueCat APIキーなし
- AdMob production ad unitなし

現在のPRは、プロダクトの中心を「譜面電卓」から「Cueを聴いて入るマイクロ合奏」へ移すための縦切りです。