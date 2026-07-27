# PartCue アーキテクチャメモ

## Model

`MusicModels.swift` が楽譜上の意味を持つデータを管理する。
画面上のX座標やY座標は保存しない。

## ViewModel

`ScoreEditorViewModel` が以下を管理する。

- 選択中の音価
- 臨時記号と付点
- 現在の入力拍
- 音符イベント配列
- 入力可能性の判定
- Undo
- 入力モードと再生モード
- 再生位置

## View

Viewは状態を表示し、ユーザー操作をViewModelへ渡す。
五線譜の描画とタップ座標変換は`StaffView`が担当する。

## Service

- `HapticService`: 触覚フィードバック
- `TonePlaybackEngine`: 音声生成と再生

## データから表示への変換

- `startBeat` → X座標
- `Pitch.staffOffset` → Y座標
- `NoteDuration` → 符頭・符幹・旗
- `playbackBeat` → 再生カーソル

## 今回あえて簡略化した点

設計を理解しやすくするため、永続化・DIコンテナ・Repository・UseCase層は入れていない。
MVPの責務が増えた段階で分割する。
