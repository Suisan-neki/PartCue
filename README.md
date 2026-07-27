# PartCue 0.1.0

分からない1小節だけをiPhoneで入力し、すぐ音で確認する譜読み支援アプリのプロトタイプです。

## 現在できること

- iPhone横向き専用の入力UI
- 2分・4分・8分・16分音符の選択
- 五線譜タップによる音高入力
- 自動カーソル移動
- 休符入力
- ♯・♭・♮・付点
- Undo
- 4/4の1小節を超える入力の防止
- 音符配置・小節完成・エラー時のハプティクス
- 入力した1小節の簡易トーン再生
- 再生カーソルと現在音符の強調
- 入力モードと再生モードの切り替え

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

ハプティクスはシミュレータでは確認できないため、実機で試してください。

## MVPの制約

- 4/4固定
- 1小節固定
- ヘ音記号固定
- 単旋律のみ
- 保存なし
- 複数パートなし
- 再生音は外部音源を使わない簡易トーン
- タイ・連符・スラー・強弱・調号は未対応

## 読み解く順番

1. `Models/MusicModels.swift`
   - 音価、音高、臨時記号、音符イベントの定義
2. `ViewModels/ScoreEditorViewModel.swift`
   - 入力状態と操作ロジック
3. `Views/StaffView.swift`
   - 拍からX座標、音高からY座標への変換と描画
4. `Services/TonePlaybackEngine.swift`
   - 音符イベントからPCM音声を生成して再生
5. `Views/ScoreEditorView.swift` と `Views/PlaybackView.swift`
   - Canva案をSwiftUIへ落とした画面構成

## 次に直す候補

- 音符・休符・ヘ音記号の見た目を浄書寄りに調整
- テンポ編集UI
- 3/4・6/8対応
- ト音記号対応
- 複数パートを縦に並べて同時再生
- SwiftDataによるカード保存
- 実際の楽器音源
- タイと連符
