# PartCue Catvertising Strategy

## 1. 方針

PartCueは、広告を消すための買い切り課金を中心にしません。

従来の広告が嫌われる原因は、広告の存在そのものだけではありません。

- 作業中に割り込む
- いつ出るか分からない
- ミスや失敗の直後に出る
- 音量や画面を突然奪う
- 同じ広告を何度も見せる
- 見ない選択がない

PartCueでは広告クリエイティブの品質を直接制御できなくても、広告を出す文脈、タイミング、遷移、頻度、選択権を設計します。

目指すのはテレビCMのような「章と章の間にある短い区切り」です。

## 2. 中心コンセプト

### Sponsored Intermission

3回の練習を1セットとします。

セット完了後だけ、インターミッションを提案します。

広告は自動表示しません。

ユーザーは次から選びます。

- 広告を見る
- 広告を見ずに続ける
- セッションを終える

広告を選んだ場合はRewarded Adを表示します。

完了したユーザーには、そのセッション内で使える詳細フィードバックを付与します。

候補:

- Early / Lateのミリ秒推移
- 直近3回の比較
- タイミング分布
- 将来の音高判定

基本的なCue練習は広告を見なくても使えます。

## 3. 出してはいけない場所

以下では広告を表示しません。

- アプリ起動直後
- 音符入力中
- Undo直後
- Cue再生中
- Rehearse中
- マイク収録中
- 失敗判定の直後
- 結果が表示される前
- 画面遷移のたび

## 4. Placement

### `session_intermission_rewarded`

形式:

- Rewarded Ad

表示条件:

- 3回の練習セット完了後
- 再生と録音が完全に停止している
- ユーザーが明示的に選択した
- 同一セットでは1回まで

報酬:

- 現在のセッションに対する詳細フィードバック

### `session_summary_native`

形式:

- Native Ad

表示条件:

- ユーザーが明示的にセッションを終了した後
- 練習結果と広告を視覚的に分離する
- 1セッション1回まで

見せ方:

- 演奏会プログラムの協賛欄に近い静かなカード
- 広告であることを明確に表示
- 結果のCTAと広告のCTAを近づけない
- 広告を閉じなくても結果を読める

## 5. インターミッションの遷移

1. 3回目の練習が完了する
2. 結果を通常どおり表示する
3. 画面下部へ「インターミッション」の控えめな導線を出す
4. ユーザーが押す
5. 広告を見る場合の報酬を明示する
6. 広告を見るか、見ずに続けるかを選ぶ
7. 広告完了後に報酬を付与する
8. 次のセットへ戻る

広告を結果より先に出しません。

## 6. 実装構成

広告配信:

- Google AdMob

広告イベントと収益の追跡:

- RevenueCat Ads
- RevenueCat AdMob adapter

Rewarded Adの検証:

- AdMob Server-Side Verification
- RevenueCat verified rewards

予定するSwift Package:

```swift
.package(
    url: "https://github.com/RevenueCat/purchases-ios-admob",
    from: "5.0.0"
)
```

本番接続時は`RevenueCatAdMob`を使い、`loadAndTrack`へplacement IDを渡します。

```swift
rewardedAd = try await RewardedAd.loadAndTrack(
    withAdUnitID: adUnitID,
    request: Request(),
    placement: "session_intermission_rewarded",
    fullScreenContentDelegate: delegate
)
```

現在のPRではAPIキー、AdMob App ID、production ad unitを持たないため、広告ネットワークには接続しません。

## 7. RevenueCatで見る指標

広告収益だけでは判断しません。

### 広告指標

- Ad impressions
- Ad completion rate
- Ad revenue
- eCPM
- Fill rate
- Placement別収益

### UX指標

- インターミッション提案の表示数
- 広告の選択率
- 広告完了率
- 広告後に練習へ戻った割合
- 広告を見なかった人の継続率
- 広告表示後のセッション離脱率
- 1セッションあたりの練習回数

広告収益が増えても、練習再開率が下がる場合は失敗とみなします。

## 8. A/Bテスト候補

### タイミング

- 3回ごと
- 5回ごと
- 5分経過後

### 文言

- インターミッション
- 20秒休憩
- 次のセットへ進む前に

### 報酬

- 詳細なタイミング推移
- そのセッションの比較グラフ
- 追加の練習プリセット

## 9. 守ること

- Rewarded Adであることを事前に明示する
- 報酬を事前に明示する
- 毎回ユーザーの同意を取る
- 報酬はアプリ内の非金銭的なものにする
- 広告を見なくてもコア機能を利用できる
- 広告のクリックを促さない
- 広告クリエイティブを隠したり誤認させたりしない
- テスト中は必ずテスト広告IDを使う

## 10. Shipatonでの主張

PartCueのCatvertisingにおける主張は、広告を美しく見せることではありません。

> 広告を練習の中断ではなく、練習セットの間にユーザーが選べるインターミッションとして再設計する。

広告の内容は制御できなくても、広告が現れる文脈は制御できます。

この設計が成功したかは、広告収益だけでなく、広告の後にユーザーが練習へ戻ったかで評価します。

## 11. 参考資料

- Shipaton 2026 Catvertising Award
  - https://www.revenuecat.com/blog/company/announcing-shipaton-2026
- RevenueCat Ad Monetization
  - https://www.revenuecat.com/docs/getting-started/ad-monetization
- RevenueCat AdMob SDK Integration
  - https://www.revenuecat.com/docs/ad-monetization/admob
- RevenueCat AdMob Adapter
  - https://www.revenuecat.com/docs/getting-started/adapter-sdks/admob
- Google AdMob Rewarded Ads for iOS
  - https://developers.google.com/admob/ios/rewarded
- Google AdMob Native Ads for iOS
  - https://developers.google.com/admob/ios/native