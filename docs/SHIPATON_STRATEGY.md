# PartCue Shipaton Strategy

## One-line pitch

**PartCue turns one difficult ensemble entrance into a private micro-rehearsal.**

日本語:

**合図を聴いて入る練習を、一人でもできるようにする。**

## 解く課題

オーケストラや吹奏楽では、自分のパート譜だけを見ても入り方が分からないことがあります。

実際の入りは次のような関係で決まります。

- クラリネットの上行形が終わったら入る
- オーボエの最後の音から2拍後に入る
- チェロの刻みが変化したら準備する
- 長い休符の後、他パートの音色を合図にする

この関係は通常、合奏に行かないと練習できません。

## Before / After

### Before

1. 長い休符がある
2. 何を聴けばよいか分からない
3. 自宅では関係を再現できない
4. 合奏で初めて試し、入り損ねる

### After

1. 合図になるCUEを入力する
2. 自分の入りをYOUへ入力する
3. Togetherで重なりを理解する
4. Cue Onlyで合図を覚える
5. Rehearseで実際に自分が入る
6. 将来版ではEarly / Lateを数値で確認する

## ハッカソンで残す一画面

```text
CUE   Clarinet   ─ ♪ ♪ ♩ ─
YOU   Fagotto    ─ 休 休 ♩ ♪

[Together] [Cue Only] [Rehearse]
```

一画面で次が伝わることを優先します。

- 他パートを合図として登録する
- 自分のパートと同期して確認する
- 自分の音を消して実際に入る

## 新規性の置き場所

短い譜面の入力や再生そのものを新規性として主張しません。

新規性は次のフローに置きます。

> 他パートのCueと自分のEntryの関係を定義し、そのCueを聴いて実際に演奏し、入りだけを評価する。

## 48時間版

- CUEとYOUの2トラック
- 音符と休符の入力
- Together
- Cue Only
- Rehearse
- 再生カーソル
- 3回の練習を1セットとしたインターミッション導線

## 1週間版

- マイク入力
- 発音開始検出
- Early / Late
- ミリ秒差
- 直近3回の比較
- CueCard保存
- RevenueCat AdsによるRewarded Ad追跡

## 捨てるもの

- PDF全体の解析
- 手書き認識
- OMR
- 完璧な浄書
- 楽譜作成アプリとしての網羅性
- SNS
- コミュニティ
- AIを使っただけの指導
- 起動直後の広告
- 常時バナー

## 主に狙う賞

### Next Gen Award

- 学生の原体験
- 動くモバイルアプリ
- 公開リポジトリ
- 狭い入口と普遍的な課題構造

### RevenueCat Design Award

- 編集画面から練習画面への変形
- CueとYouの視覚的な切り替え
- 目、耳、触覚を組み合わせたフィードバック
- 再試行の短さ

### Catvertising Award

- 広告を練習中断ではなくインターミッションへ置く
- 自動表示しない
- Rewarded Adの報酬をセッション内フィードバックにする
- RevenueCatで広告後の練習再開率まで見る

## 2分デモ

### 0:00–0:12

長い休符のあるパート譜を見せる。

> You can read your notes. But your part does not tell you what to listen for.

### 0:12–0:25

> PartCue turns one difficult ensemble entrance into a private micro-rehearsal.

### 0:25–0:50

CUEとYOUを入力する。

### 0:50–1:05

Togetherを再生する。

### 1:05–1:25

Cue OnlyまたはRehearseで実際に入る。

### 1:25–1:40

将来版の結果:

```text
+132 ms
LATE
```

もう一度行う。

```text
+24 ms
EXCELLENT
```

### 1:40–1:52

```text
+240 → +132 → +24 ms
```

### 1:52–2:00

> Built by an orchestra player for the entrances you cannot practise alone.

## Build in Publicの物語

1. 1小節を鳴らすアプリとして開始した
2. プロトタイプを作った
3. 直接競合があると分かった
4. 機能ではなく自分の原体験へ戻った
5. 本当に困っていたのは他パートとのCue関係だった
6. 譜面電卓からマイクロ合奏室へ方向転換した
7. 実際の奏者の入りで検証する

このピボット自体を開発記録として公開します。