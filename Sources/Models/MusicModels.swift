import Foundation

/// 画面全体のモード。
enum EditorMode: Equatable {
    case editing
    case playback
    case intermission
}

/// CueCard内の役割。
enum TrackRole: String, CaseIterable, Identifiable, Codable {
    case cue
    case player

    var id: Self { self }

    var shortLabel: String {
        switch self {
        case .cue: "CUE"
        case .player: "YOU"
        }
    }

    var displayName: String {
        switch self {
        case .cue: "合図パート"
        case .player: "自分のパート"
        }
    }
}

/// 練習時にどのパートを鳴らすか。
enum RehearsalMode: String, CaseIterable, Identifiable, Codable {
    case together
    case cueOnly
    case rehearse

    var id: Self { self }

    var title: String {
        switch self {
        case .together: "Together"
        case .cueOnly: "Cue Only"
        case .rehearse: "Rehearse"
        }
    }

    var subtitle: String {
        switch self {
        case .together: "重なりを確認"
        case .cueOnly: "合図だけ聴く"
        case .rehearse: "自分で入る"
        }
    }

    var systemImage: String {
        switch self {
        case .together: "person.2.wave.2"
        case .cueOnly: "ear"
        case .rehearse: "music.mic"
        }
    }
}

/// MVPで扱う音価。
enum NoteDuration: Double, CaseIterable, Identifiable, Codable {
    case half = 2.0
    case quarter = 1.0
    case eighth = 0.5
    case sixteenth = 0.25

    var id: Self { self }

    var shortLabel: String {
        switch self {
        case .half: "2分"
        case .quarter: "4分"
        case .eighth: "8分"
        case .sixteenth: "16分"
        }
    }

    var accessibilityLabel: String {
        "\(shortLabel)音符"
    }

    var flagCount: Int {
        switch self {
        case .half, .quarter: 0
        case .eighth: 1
        case .sixteenth: 2
        }
    }

    var usesOpenNotehead: Bool {
        self == .half
    }
}

/// 臨時記号。次に置く1音だけへ適用する。
enum Accidental: String, CaseIterable, Identifiable, Codable {
    case sharp
    case flat
    case natural

    var id: Self { self }

    var symbol: String {
        switch self {
        case .sharp: "♯"
        case .flat: "♭"
        case .natural: "♮"
        }
    }

    var semitoneOffset: Int {
        switch self {
        case .sharp: 1
        case .flat: -1
        case .natural: 0
        }
    }
}

enum PitchLetter: Int, CaseIterable, Codable {
    case c = 0
    case d
    case e
    case f
    case g
    case a
    case b

    var name: String {
        switch self {
        case .c: "C"
        case .d: "D"
        case .e: "E"
        case .f: "F"
        case .g: "G"
        case .a: "A"
        case .b: "B"
        }
    }

    var semitoneFromC: Int {
        switch self {
        case .c: 0
        case .d: 2
        case .e: 4
        case .f: 5
        case .g: 7
        case .a: 9
        case .b: 11
        }
    }
}

/// 音高。画面座標ではなく音楽上の意味だけを持つ。
struct Pitch: Hashable, Codable {
    let letter: PitchLetter
    let octave: Int

    /// staffOffset = 0 はヘ音記号の最下線 G2。
    init(staffOffset: Int) {
        let baseDiatonicNumber = 2 * 7 + PitchLetter.g.rawValue
        let target = baseDiatonicNumber + staffOffset
        let normalizedLetter = ((target % 7) + 7) % 7
        let normalizedOctave = Int(floor(Double(target) / 7.0))

        self.letter = PitchLetter(rawValue: normalizedLetter) ?? .c
        self.octave = normalizedOctave
    }

    init(letter: PitchLetter, octave: Int) {
        self.letter = letter
        self.octave = octave
    }

    var staffOffset: Int {
        let baseDiatonicNumber = 2 * 7 + PitchLetter.g.rawValue
        return octave * 7 + letter.rawValue - baseDiatonicNumber
    }

    func midiNumber(accidental: Accidental?) -> UInt8 {
        let raw = (octave + 1) * 12
            + letter.semitoneFromC
            + (accidental?.semitoneOffset ?? 0)
        return UInt8(clamping: raw)
    }

    var displayName: String {
        "\(letter.name)\(octave)"
    }
}

/// 1つの音符または休符。
struct NoteEvent: Identifiable, Hashable, Codable {
    let id: UUID
    let startBeat: Double
    let duration: NoteDuration
    let pitch: Pitch?
    let accidental: Accidental?
    let isDotted: Bool

    init(
        id: UUID = UUID(),
        startBeat: Double,
        duration: NoteDuration,
        pitch: Pitch?,
        accidental: Accidental? = nil,
        isDotted: Bool = false
    ) {
        self.id = id
        self.startBeat = startBeat
        self.duration = duration
        self.pitch = pitch
        self.accidental = accidental
        self.isDotted = isDotted
    }

    var isRest: Bool { pitch == nil }

    var effectiveBeats: Double {
        duration.rawValue * (isDotted ? 1.5 : 1.0)
    }

    var endBeat: Double {
        startBeat + effectiveBeats
    }
}

/// Cueと自分のパートを対にした練習単位。
struct CueCard: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var cueInstrumentName: String
    var playerInstrumentName: String
    var bpm: Double
    var measureBeats: Double
    var cueEvents: [NoteEvent]
    var playerEvents: [NoteEvent]

    init(
        id: UUID = UUID(),
        title: String,
        cueInstrumentName: String,
        playerInstrumentName: String,
        bpm: Double = 72,
        measureBeats: Double = 4,
        cueEvents: [NoteEvent] = [],
        playerEvents: [NoteEvent] = []
    ) {
        self.id = id
        self.title = title
        self.cueInstrumentName = cueInstrumentName
        self.playerInstrumentName = playerInstrumentName
        self.bpm = bpm
        self.measureBeats = measureBeats
        self.cueEvents = cueEvents
        self.playerEvents = playerEvents
    }
}

/// 将来のマイク判定で保存する1回分の試行。
struct PracticeAttempt: Identifiable, Hashable, Codable {
    let id: UUID
    let createdAt: Date
    let rehearsalMode: RehearsalMode
    let timingOffsetMilliseconds: Double?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        rehearsalMode: RehearsalMode,
        timingOffsetMilliseconds: Double? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.rehearsalMode = rehearsalMode
        self.timingOffsetMilliseconds = timingOffsetMilliseconds
    }
}