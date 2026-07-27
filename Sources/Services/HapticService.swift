import UIKit

/// ハプティクスをViewやViewModelへ散らさないための小さなラッパー。
final class HapticService {
    private let selection = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()

    init() {
        prepare()
    }

    func prepare() {
        selection.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        notification.prepare()
    }

    func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }

    func notePlaced() {
        lightImpact.impactOccurred(intensity: 0.65)
        lightImpact.prepare()
    }

    func measureCompleted() {
        mediumImpact.impactOccurred(intensity: 0.9)
        mediumImpact.prepare()
    }

    func undo() {
        lightImpact.impactOccurred(intensity: 0.35)
        lightImpact.prepare()
    }

    func playbackStarted() {
        mediumImpact.impactOccurred(intensity: 0.55)
        mediumImpact.prepare()
    }

    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
}
