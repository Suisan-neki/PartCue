import AVFAudio
import Foundation

struct TonePlaybackTrack {
    let role: TrackRole
    let events: [NoteEvent]
}

/// 外部音源なしで動く、MVP用の簡易アンサンブル再生エンジン。
/// CueとYouを同じPCMバッファへ描画し、サンプル単位で同期させる。
final class TonePlaybackEngine {
    enum PlaybackError: LocalizedError {
        case bufferCreationFailed

        var errorDescription: String? {
            switch self {
            case .bufferCreationFailed:
                "再生用の音声バッファを作成できませんでした。"
            }
        }
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private lazy var format = AVAudioFormat(
        standardFormatWithSampleRate: sampleRate,
        channels: 2
    )!

    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.75
    }

    @discardableResult
    func play(
        tracks: [TonePlaybackTrack],
        bpm: Double,
        measureBeats: Double,
        completion: @escaping () -> Void
    ) throws -> TimeInterval {
        stop()
        try configureAudioSession()

        if !engine.isRunning {
            engine.prepare()
            try engine.start()
        }

        let secondsPerBeat = 60.0 / max(bpm, 1)
        let totalDuration = measureBeats * secondsPerBeat
        let frameCount = AVAudioFrameCount(ceil(totalDuration * sampleRate))

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else {
            throw PlaybackError.bufferCreationFailed
        }

        buffer.frameLength = frameCount
        guard let channels = buffer.floatChannelData else {
            throw PlaybackError.bufferCreationFailed
        }

        for channelIndex in 0..<Int(format.channelCount) {
            channels[channelIndex].update(repeating: 0, count: Int(frameCount))
        }

        for track in tracks {
            for event in track.events where !event.isRest {
                guard let pitch = event.pitch else { continue }
                render(
                    event: event,
                    pitch: pitch,
                    role: track.role,
                    secondsPerBeat: secondsPerBeat,
                    into: channels,
                    frameCount: Int(frameCount)
                )
            }
        }

        player.scheduleBuffer(buffer, at: nil, options: []) {
            completion()
        }
        player.play()

        return totalDuration
    }

    func stop() {
        if player.isPlaying {
            player.stop()
        }
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
    }

    private func render(
        event: NoteEvent,
        pitch: Pitch,
        role: TrackRole,
        secondsPerBeat: Double,
        into channels: UnsafePointer<UnsafeMutablePointer<Float>>,
        frameCount: Int
    ) {
        let midi = Double(pitch.midiNumber(accidental: event.accidental))
        let frequency = 440.0 * pow(2.0, (midi - 69.0) / 12.0)
        let startSeconds = event.startBeat * secondsPerBeat
        let nominalDuration = event.effectiveBeats * secondsPerBeat
        let soundingDuration = max(0.04, nominalDuration * 0.92)

        let startFrame = max(0, Int(startSeconds * sampleRate))
        let endFrame = min(frameCount, startFrame + Int(soundingDuration * sampleRate))
        guard endFrame > startFrame else { return }

        let attackSeconds = min(0.012, soundingDuration * 0.15)
        let releaseSeconds = min(0.045, soundingDuration * 0.22)
        let amplitude = 0.15
        let channelGains = gains(for: role)

        for frame in startFrame..<endFrame {
            let localTime = Double(frame - startFrame) / sampleRate
            let remainingTime = soundingDuration - localTime

            let attackEnvelope = min(1.0, localTime / max(attackSeconds, 0.001))
            let releaseEnvelope = min(1.0, remainingTime / max(releaseSeconds, 0.001))
            let envelope = max(0.0, min(attackEnvelope, releaseEnvelope))

            let fundamental = sin(2.0 * .pi * frequency * localTime)
            let overtone: Double
            switch role {
            case .cue:
                overtone = 0.12 * sin(2.0 * .pi * frequency * 3.0 * localTime)
            case .player:
                overtone = 0.18 * sin(2.0 * .pi * frequency * 2.0 * localTime)
            }

            let sample = Float((fundamental + overtone) / 1.18 * amplitude * envelope)
            channels[0][frame] += sample * channelGains.left
            channels[1][frame] += sample * channelGains.right
        }
    }

    private func gains(for role: TrackRole) -> (left: Float, right: Float) {
        switch role {
        case .cue:
            (left: 1.0, right: 0.58)
        case .player:
            (left: 0.58, right: 1.0)
        }
    }
}