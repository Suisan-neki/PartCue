# PartCue 0.2.0

**合図を聴いて入る練習を、一人でもできるようにする。**

PartCueは、オーケストラや吹奏楽で難しい「入り」を小さな練習単位へ変えるiPhoneアプリです。

従来の0.1.0は、分からない1小節を手入力して再生するプロトタイプでした。しかし短い譜面の入力と再生だけでは既存の楽譜ツールとの差が弱く、本来の原体験も十分に表せていませんでした。

0.2.0では、他パートの合図を表す **CUE** と、自分の入りを表す **YOU** を並べます。両方を聴く、合図だけを聴く、実際に自分で入るという3段階で、一つの入りを反復練習できる形へ方向転換しています。

> PartCue turns one difficult ensemble entrance into a private micro-rehearsal.

## 現在できること

- iPhone横向き専用の入力UI
- CUEとYOUの2段譜面
- 編集対象パートの切り替え
- 2分・4分・8分・16分音符
- 五線譜タップによる音高入力
- 自動カーソル移動
- 休符
- ♯・♭・♮・付点
- パートごとのUndo
- 4/4の1小節を超える入力の防止
- 音符配置・小節完成・エラー時のハプティクス
- CueとYouの同期トーン再生
- Together / Cue Only / Rehearseの3モード
- 再生カーソルと現在音符の強調
- 3回の練習を1セットとしたインターミッション導線
- ユーザーが明示的に選ぶ広告付き休憩のUXプレビュー

## 広告体験の方針

PartCueでは、バナー広告や起動直後の広告を採用しません。

広告は以下の時間には表示しません。

- 音符の入力中
- Cueの再生中
- ユーザーが実際に入る練習中
- ミスの直後

3回の練習セットが終わった自然な区切りでのみ、インターミッションを提案します。広告は自動表示せず、ユーザーが明示的に選んだ場合だけ表示します。

将来的にはAdMobのRewarded AdをRevenueCat Adsで追跡し、広告を完了したユーザーへ、そのセッションの詳細フィードバックを開放します。

現在の画面は広告配置と遷移を検証するためのプレビューです。広告ネットワークにはまだ接続していません。

詳しくは [`docs/CATVERTISING.md`](docs/CATVERTISING.md) を参照してください。

## 開き方

### Swift Playgrounds

1. `PartCue.swiftpm` フォルダをiCloud Driveまたはローカルへ置く
2. Swift Playgroundsで「プレイグラウンドを開く」を選ぶ
3. `PartCue.swiftpm` を開く
4. 実機iPhoneを横向きにして実行する

### Xcode

1. `PartCue.swiftpm` をXcodeで開く
2. Signing & Capabilitiesで自分のTeamを選ぶ
3. iPhoneシミュレータまたは実機を選ぶ
4. Runする

ハプティクスはシミュレータでは確認できません。

## MVPの制約

- 4/4固定
- CUEとYOUは各1小節固定
- ヘ音記号固定
- 各パートは単旋律のみ
- 保存なし
- 再生音は外部音源を使わない簡易トーン
- タイ・連符・スラー・強弱・調号は未対応
- マイクによる入りの判定は未実装
- RevenueCat Ads / AdMobは未接続

## 読み解く順番

1. `Models/MusicModels.swift`
   - 音価、音高、CueCard、TrackRole、RehearsalMode
2. `ViewModels/ScoreEditorViewModel.swift`
   - 2トラックの入力状態と練習セッション
3. `Views/ScoreEditorView.swift`
   - CUEとYOUを並べる編集画面
4. `Services/TonePlaybackEngine.swift`
   - 2トラックを同一バッファへ同期描画する簡易再生
5. `Views/PlaybackView.swift`
   - Together / Cue Only / Rehearse
6. `Views/IntermissionView.swift`
   - 練習を邪魔しない広告付き休憩のUX
7. `Services/AdExperienceService.swift`
   - 広告SDKを差し込むための境界と表示ポリシー

## 次に実装するもの

- マイク入力による発音開始検出
- 予定された入りと実際の入りの時間差
- Early / Lateとミリ秒差の表示
- RevenueCat AdMob adapterによるRewarded Ad追跡
- セッション終了時のNative Ad
- 練習結果の履歴
- CueCardの保存
- テンポ編集
- ト音記号
- 3/4・6/8

## Shipatonで狙う体験

Before:

- 長い休符のあと、何を聴けば入れるのか分からない
- 合奏に行くまで入りの関係を練習できない

After:

1. CUEとYOUを入力する
2. Togetherで重なりを理解する
3. Cue Onlyで合図を覚える
4. Rehearseで実際に入る
5. 将来版ではEarly / Lateを数値で確認する

## License

MIT License. See [`LICENSE`](LICENSE).