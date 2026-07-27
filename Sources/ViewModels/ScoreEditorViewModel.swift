import Combine
import Foundation

@MainActor
final class ScoreEditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .editing
    @Published var selectedDuration: NoteDuration = .quarter
    @Published var selectedAccidental: Accidental?
    @Published var isDotted = false
    @Published var events: [NoteEvent] = []
    @Published var currentBeat: Double = 0
    @Published var bpm: Double = 72
    @Published var isPlaying = false
    @Published var playbackBeat: Double = 0
    @Published var errorMessage: String?

    let title = "Fagotto / Bの4小節前"
    let measureBeats: Double = 4

    private let haptics: HapticService
    private let playbackEngine: TonePlaybackEngine
    private var playbackTimer: Timer?
    private var playbackStartedAt: Date?
    private var playbackDuration: TimeInterval = 0
    private var playbackToken: UUID?

    init(
        haptics: HapticService = HapticService(),
        playbackEngine: TonePlaybackEngine = TonePlaybackEngine()
    ) {
        self.haptics = haptics
        self.playbackEngine = playbackEngine
    }

    var remainingBeats: Double {
        max(0, measureBeats - currentBeat)
    }

    var isMeasureComplete: Bool {
        abs(currentBeat - measureBeats) < 0.0001
    }

    var currentSelectionLabel: String {
        var parts = [selectedDuration.accessibilityLabel]
        if let selectedAccidental {
            parts.append(selectedAccidental.symbol)
        }
        if isDotted {
            parts.append("付点")
        }
        return "次：" + parts.joined(separator: "・")
    }

    var activePlaybackEventID: UUID? {
        events.first(where: {
            playbackBeat >= $0.startBeat && playbackBeat < $0.endBeat
        })?.id
    }

    func selectDuration(_ duration: NoteDuration) {
        selectedDuration = duration
        haptics.selectionChanged()
    }

    func toggleAccidental(_ accidental: Accidental) {
        selectedAccidental = selectedAccidental == accidental ? nil : accidental
        haptics.selectionChanged()
    }

    func toggleDotted() {
        isDotted.toggle()
        haptics.selectionChanged()
    }

    func addNote(pitch: Pitch) {
        let event = NoteEvent(
            startBeat: currentBeat,
            duration: selectedDuration,
            pitch: pitch,
            accidental: selectedAccidental,
            isDotted: isDotted
        )
        append(event)
    }

    func addRest() {
        let event = NoteEvent(
            startBeat: currentBeat,
            duration: selectedDuration,
            pitch: nil,
            accidental: nil,
            isDotted: isDotted
        )
        append(event)
    }

    func undo() {
        guard let removed = events.popLast() else {
            haptics.error()
            return
        }

        currentBeat = removed.startBeat
        selectedAccidental = nil
        isDotted = false
        haptics.undo()
    }

    func enterPlayback() {
        guard !events.isEmpty else {
            errorMessage = "音符または休符を1つ以上入力してください。"
            haptics.error()
            return
        }

        mode = .playback
        startPlayback()
    }

    func startPlayback() {
        stopPlayback(resetPosition: true)

        do {
            let token = UUID()
            playbackToken = token
            playbackDuration = try playbackEngine.play(
                events: events,
                bpm: bpm,
                measureBeats: measureBeats
            ) { [weak self] in
                Task { @MainActor in
                    guard self?.playbackToken == token else { return }
                    self?.finishPlayback()
                }
            }

            playbackStartedAt = Date()
            playbackBeat = 0
            isPlaying = true
            startPlaybackTimer()
            haptics.playbackStarted()
        } catch {
            playbackToken = nil
            errorMessage = error.localizedDescription
            isPlaying = false
            mode = .editing
            haptics.error()
        }
    }

    func stopPlayback(resetPosition: Bool = false) {
        playbackEngine.stop()
        playbackTimer?.invalidate()
        playbackTimer = nil
        playbackStartedAt = nil
        playbackToken = nil
        isPlaying = false

        if resetPosition {
            playbackBeat = 0
        }
    }

    func returnToEditing() {
        stopPlayback(resetPosition: true)
        mode = .editing
    }

    private func append(_ event: NoteEvent) {
        guard event.endBeat <= measureBeats + 0.0001 else {
            errorMessage = "この音価では小節を超えてしまいます。"
            haptics.error()
            return
        }

        events.append(event)
        currentBeat = min(measureBeats, event.endBeat)
        selectedAccidental = nil
        isDotted = false

        if isMeasureComplete {
            haptics.measureCompleted()
        } else {
            haptics.notePlaced()
        }
    }

    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePlaybackProgress()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        playbackTimer = timer
    }

    private func updatePlaybackProgress() {
        guard isPlaying, let playbackStartedAt else { return }
        let elapsed = Date().timeIntervalSince(playbackStartedAt)
        let secondsPerBeat = 60.0 / max(bpm, 1)
        playbackBeat = min(measureBeats, elapsed / secondsPerBeat)

        if elapsed >= playbackDuration {
            finishPlayback()
        }
    }

    private func finishPlayback() {
        guard isPlaying else { return }
        playbackTimer?.invalidate()
        playbackTimer = nil
        playbackStartedAt = nil
        playbackToken = nil
        playbackBeat = measureBeats
        isPlaying = false
    }
}
