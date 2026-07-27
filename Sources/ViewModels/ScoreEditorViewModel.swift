import Combine
import Foundation

@MainActor
final class ScoreEditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .editing
    @Published var selectedTrack: TrackRole = .cue
    @Published var selectedDuration: NoteDuration = .quarter
    @Published var selectedAccidental: Accidental?
    @Published var isDotted = false

    @Published var cueEvents: [NoteEvent] = []
    @Published var playerEvents: [NoteEvent] = []
    @Published var cueCurrentBeat: Double = 0
    @Published var playerCurrentBeat: Double = 0

    @Published var bpm: Double = 72
    @Published var rehearsalMode: RehearsalMode = .together
    @Published var isPlaying = false
    @Published var playbackBeat: Double = 0
    @Published var errorMessage: String?

    @Published var completedRuns = 0
    @Published var shouldOfferIntermission = false
    @Published var detailedFeedbackUnlocked = false

    let title = "Bの4小節前"
    let cueInstrumentName = "Clarinet"
    let playerInstrumentName = "Fagotto"
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

    var selectedEvents: [NoteEvent] {
        events(for: selectedTrack)
    }

    var selectedCurrentBeat: Double {
        currentBeat(for: selectedTrack)
    }

    var selectedTrackHasEvents: Bool {
        !selectedEvents.isEmpty
    }

    var remainingBeats: Double {
        max(0, measureBeats - selectedCurrentBeat)
    }

    var isSelectedTrackComplete: Bool {
        abs(selectedCurrentBeat - measureBeats) < 0.0001
    }

    var canStartRehearsal: Bool {
        !cueEvents.isEmpty && !playerEvents.isEmpty
    }

    var currentSelectionLabel: String {
        var parts = [selectedTrack.shortLabel, selectedDuration.accessibilityLabel]
        if let selectedAccidental {
            parts.append(selectedAccidental.symbol)
        }
        if isDotted {
            parts.append("付点")
        }
        return "次：" + parts.joined(separator: "・")
    }

    var activeCueEventID: UUID? {
        activeEventID(in: cueEvents)
    }

    var activePlayerEventID: UUID? {
        activeEventID(in: playerEvents)
    }

    var intermissionProgressLabel: String {
        "\(min(completedRuns % AdExperiencePolicy.runsPerIntermission, AdExperiencePolicy.runsPerIntermission)) / \(AdExperiencePolicy.runsPerIntermission) runs"
    }

    func events(for role: TrackRole) -> [NoteEvent] {
        switch role {
        case .cue: cueEvents
        case .player: playerEvents
        }
    }

    func currentBeat(for role: TrackRole) -> Double {
        switch role {
        case .cue: cueCurrentBeat
        case .player: playerCurrentBeat
        }
    }

    func isTrackComplete(_ role: TrackRole) -> Bool {
        abs(currentBeat(for: role) - measureBeats) < 0.0001
    }

    func instrumentName(for role: TrackRole) -> String {
        switch role {
        case .cue: cueInstrumentName
        case .player: playerInstrumentName
        }
    }

    func selectTrack(_ role: TrackRole) {
        selectedTrack = role
        selectedAccidental = nil
        isDotted = false
        haptics.selectionChanged()
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

    func addNote(pitch: Pitch, to role: TrackRole? = nil) {
        let targetRole = role ?? selectedTrack
        if selectedTrack != targetRole {
            selectTrack(targetRole)
        }

        let event = NoteEvent(
            startBeat: currentBeat(for: targetRole),
            duration: selectedDuration,
            pitch: pitch,
            accidental: selectedAccidental,
            isDotted: isDotted
        )
        append(event, to: targetRole)
    }

    func addRest() {
        let event = NoteEvent(
            startBeat: selectedCurrentBeat,
            duration: selectedDuration,
            pitch: nil,
            accidental: nil,
            isDotted: isDotted
        )
        append(event, to: selectedTrack)
    }

    func undo() {
        switch selectedTrack {
        case .cue:
            guard let removed = cueEvents.popLast() else {
                haptics.error()
                return
            }
            cueCurrentBeat = removed.startBeat
        case .player:
            guard let removed = playerEvents.popLast() else {
                haptics.error()
                return
            }
            playerCurrentBeat = removed.startBeat
        }

        selectedAccidental = nil
        isDotted = false
        haptics.undo()
    }

    func enterPlayback(mode: RehearsalMode = .together) {
        guard validatePlayback(mode) else { return }
        self.mode = .playback
        startPlayback(mode: mode)
    }

    func startPlayback(mode: RehearsalMode? = nil) {
        let targetMode = mode ?? rehearsalMode
        guard validatePlayback(targetMode) else { return }

        stopPlayback(resetPosition: true)
        rehearsalMode = targetMode

        do {
            let token = UUID()
            playbackToken = token
            playbackDuration = try playbackEngine.play(
                tracks: playbackTracks(for: targetMode),
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

    func presentIntermission() {
        guard shouldOfferIntermission else { return }
        stopPlayback(resetPosition: true)
        mode = .intermission
    }

    func skipIntermission() {
        shouldOfferIntermission = false
        mode = .playback
    }

    func completeSponsoredIntermission() {
        detailedFeedbackUnlocked = true
        shouldOfferIntermission = false
        mode = .playback
        haptics.measureCompleted()
    }

    private func append(_ event: NoteEvent, to role: TrackRole) {
        guard event.endBeat <= measureBeats + 0.0001 else {
            errorMessage = "この音価では小節を超えてしまいます。"
            haptics.error()
            return
        }

        switch role {
        case .cue:
            cueEvents.append(event)
            cueCurrentBeat = min(measureBeats, event.endBeat)
        case .player:
            playerEvents.append(event)
            playerCurrentBeat = min(measureBeats, event.endBeat)
        }

        selectedAccidental = nil
        isDotted = false

        if isTrackComplete(role) {
            haptics.measureCompleted()
        } else {
            haptics.notePlaced()
        }
    }

    private func validatePlayback(_ mode: RehearsalMode) -> Bool {
        let isValid: Bool
        switch mode {
        case .together:
            isValid = !cueEvents.isEmpty || !playerEvents.isEmpty
        case .cueOnly:
            isValid = !cueEvents.isEmpty
        case .rehearse:
            isValid = !cueEvents.isEmpty && !playerEvents.isEmpty
        }

        guard isValid else {
            errorMessage = mode == .rehearse
                ? "合図パートと自分のパートを入力してください。"
                : "再生する音符を入力してください。"
            haptics.error()
            return false
        }
        return true
    }

    private func playbackTracks(for mode: RehearsalMode) -> [TonePlaybackTrack] {
        switch mode {
        case .together:
            return [
                TonePlaybackTrack(role: .cue, events: cueEvents),
                TonePlaybackTrack(role: .player, events: playerEvents)
            ]
        case .cueOnly, .rehearse:
            return [TonePlaybackTrack(role: .cue, events: cueEvents)]
        }
    }

    private func activeEventID(in events: [NoteEvent]) -> UUID? {
        events.first(where: {
            playbackBeat >= $0.startBeat && playbackBeat < $0.endBeat
        })?.id
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

        completedRuns += 1
        if completedRuns.isMultiple(of: AdExperiencePolicy.runsPerIntermission) {
            shouldOfferIntermission = true
        }
    }
}