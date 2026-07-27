import Foundation

/// 広告を練習の邪魔にしないためのプロダクト上の不変条件。
/// 実際のRevenueCat Ads / AdMob接続は別PRでこの境界へ差し込む。
enum AdExperiencePolicy {
    static let runsPerIntermission = 3
    static let placementID = "session_intermission_rewarded"
    static let summaryPlacementID = "session_summary_native"

    /// 広告を自動表示しない。ユーザーが明示的に選んだ場合だけ表示する。
    static let requiresExplicitOptIn = true

    /// 編集中・再生中・結果表示直後には広告を出さない。
    static let allowsAdsDuringActivePractice = false
}

/// RevenueCat Adsと広告SDKをUIから切り離すための境界。
@MainActor
protocol IntermissionAdServing: AnyObject {
    var isReady: Bool { get }
    func preload() async
    func present(onReward: @escaping () -> Void)
}

/// 広告SDK接続前のUI検証用実装。
/// 本番広告を装わないよう、呼び出し側では必ず「プレビュー」と表示する。
@MainActor
final class PreviewIntermissionAdService: IntermissionAdServing {
    private(set) var isReady = true

    func preload() async {
        isReady = true
    }

    func present(onReward: @escaping () -> Void) {
        onReward()
    }
}