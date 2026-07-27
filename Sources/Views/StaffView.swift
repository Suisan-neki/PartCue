import SwiftUI

struct StaffView: View {
    let events: [NoteEvent]
    let currentBeat: Double
    let measureBeats: Double
    var playbackBeat: Double?
    var activeEventID: UUID?
    var isInteractive: Bool
    var onPitchTapped: ((Pitch) -> Void)?

    var body: some View {
        GeometryReader { proxy in
            let metrics = StaffMetrics(size: proxy.size, measureBeats: measureBeats)

            Canvas(rendersAsynchronously: true) { context, _ in
                drawBackground(context: &context, metrics: metrics)
                drawStaff(context: &context, metrics: metrics)
                drawClef(context: &context, metrics: metrics)
                drawBeatGuides(context: &context, metrics: metrics)

                if events.isEmpty && isInteractive {
                    drawInputHint(context: &context, metrics: metrics)
                }

                for event in events {
                    draw(
                        event: event,
                        isActive: event.id == activeEventID,
                        context: &context,
                        metrics: metrics
                    )
                }

                if isInteractive {
                    drawCursor(
                        beat: currentBeat,
                        color: .accentColor,
                        context: &context,
                        metrics: metrics
                    )
                }

                if let playbackBeat {
                    drawCursor(
                        beat: playbackBeat,
                        color: .orange,
                        context: &context,
                        metrics: metrics
                    )
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        guard isInteractive else { return }
                        let pitch = metrics.pitch(forY: value.location.y)
                        onPitchTapped?(pitch)
                    }
            )
        }
        .background(Color(uiColor: .systemBackground))
        .accessibilityLabel("五線譜入力エリア")
        .accessibilityHint(isInteractive ? "タップした高さに音符を置きます" : "入力した小節を再生表示します")
    }

    private func drawBackground(context: inout GraphicsContext, metrics: StaffMetrics) {
        var background = Path()
        background.addRect(CGRect(origin: .zero, size: metrics.size))
        context.fill(
            background,
            with: .color(Color(uiColor: .systemBackground))
        )
    }

    private func drawStaff(context: inout GraphicsContext, metrics: StaffMetrics) {
        for lineIndex in 0..<5 {
            let y = metrics.topLineY + CGFloat(lineIndex) * metrics.lineSpacing
            var path = Path()
            path.move(to: CGPoint(x: metrics.staffLeft, y: y))
            path.addLine(to: CGPoint(x: metrics.staffRight, y: y))
            context.stroke(path, with: .color(.primary), lineWidth: 2.1)
        }

        for x in [metrics.staffLeft, metrics.staffRight] {
            var barline = Path()
            barline.move(to: CGPoint(x: x, y: metrics.topLineY - 4))
            barline.addLine(to: CGPoint(x: x, y: metrics.bottomLineY + 4))
            context.stroke(barline, with: .color(.primary), lineWidth: 2.5)
        }
    }

    private func drawClef(context: inout GraphicsContext, metrics: StaffMetrics) {
        let clef = Text("𝄢")
            .font(.system(size: metrics.lineSpacing * 5.2, weight: .regular))
            .foregroundColor(.primary)

        context.draw(
            clef,
            at: CGPoint(
                x: metrics.clefCenterX,
                y: metrics.staffCenterY + metrics.lineSpacing * 0.05
            ),
            anchor: .center
        )
    }

    private func drawInputHint(context: inout GraphicsContext, metrics: StaffMetrics) {
        let hint = Text("音価を選び、五線譜の高さをタップ")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
        context.draw(
            hint,
            at: CGPoint(
                x: (metrics.noteAreaLeft + metrics.staffRight) / 2,
                y: metrics.bottomLineY + metrics.lineSpacing * 1.45
            ),
            anchor: .center
        )
    }

    private func drawBeatGuides(context: inout GraphicsContext, metrics: StaffMetrics) {
        for beat in 1..<Int(measureBeats) {
            let x = metrics.x(forBeat: Double(beat))
            var path = Path()
            path.move(to: CGPoint(x: x, y: metrics.topLineY - metrics.lineSpacing * 0.8))
            path.addLine(to: CGPoint(x: x, y: metrics.bottomLineY + metrics.lineSpacing * 0.8))
            context.stroke(
                path,
                with: .color(Color.secondary.opacity(0.14)),
                style: StrokeStyle(lineWidth: 1, dash: [3, 5])
            )
        }
    }

    private func draw(
        event: NoteEvent,
        isActive: Bool,
        context: inout GraphicsContext,
        metrics: StaffMetrics
    ) {
        let x = metrics.x(forBeat: event.startBeat)

        if isActive {
            let highlight = CGRect(
                x: x - metrics.lineSpacing * 0.9,
                y: metrics.topLineY - metrics.lineSpacing,
                width: metrics.lineSpacing * 1.8,
                height: metrics.lineSpacing * 6
            )
            context.fill(
                Path(roundedRect: highlight, cornerRadius: metrics.lineSpacing * 0.6),
                with: .color(Color.orange.opacity(0.14))
            )
        }

        if event.isRest {
            drawRest(event: event, x: x, context: &context, metrics: metrics)
            return
        }

        guard let pitch = event.pitch else { return }
        let y = metrics.y(forPitch: pitch)

        drawLedgerLines(for: pitch, x: x, context: &context, metrics: metrics)

        if let accidental = event.accidental {
            let accidentalText = Text(accidental.symbol)
                .font(.system(size: metrics.lineSpacing * 1.45, weight: .regular, design: .serif))
                .foregroundColor(.primary)
            context.draw(
                accidentalText,
                at: CGPoint(x: x - metrics.lineSpacing * 0.9, y: y),
                anchor: .center
            )
        }

        let headWidth = metrics.lineSpacing * 1.10
        let headHeight = metrics.lineSpacing * 0.72
        let headRect = CGRect(
            x: x - headWidth / 2,
            y: y - headHeight / 2,
            width: headWidth,
            height: headHeight
        )
        let head = Path(ellipseIn: headRect)

        if event.duration.usesOpenNotehead {
            context.stroke(head, with: .color(.primary), lineWidth: 2.2)
        } else {
            context.fill(head, with: .color(.primary))
        }

        let stemUp = pitch.staffOffset < 4
        let stemX = stemUp ? headRect.maxX - 1 : headRect.minX + 1
        let stemEndY = stemUp
            ? y - metrics.lineSpacing * 3.0
            : y + metrics.lineSpacing * 3.0

        var stem = Path()
        stem.move(to: CGPoint(x: stemX, y: y))
        stem.addLine(to: CGPoint(x: stemX, y: stemEndY))
        context.stroke(stem, with: .color(.primary), lineWidth: 2.2)

        for flagIndex in 0..<event.duration.flagCount {
            let direction: CGFloat = stemUp ? 1 : -1
            let verticalOffset = CGFloat(flagIndex) * metrics.lineSpacing * direction * 0.65
            var flag = Path()
            flag.move(to: CGPoint(x: stemX, y: stemEndY + verticalOffset))
            flag.addCurve(
                to: CGPoint(
                    x: stemX + metrics.lineSpacing * 1.25,
                    y: stemEndY + direction * metrics.lineSpacing * 1.15 + verticalOffset
                ),
                control1: CGPoint(
                    x: stemX + metrics.lineSpacing * 0.85,
                    y: stemEndY + direction * metrics.lineSpacing * 0.15 + verticalOffset
                ),
                control2: CGPoint(
                    x: stemX + metrics.lineSpacing * 1.25,
                    y: stemEndY + direction * metrics.lineSpacing * 0.75 + verticalOffset
                )
            )
            context.stroke(flag, with: .color(.primary), lineWidth: 2.2)
        }

        if event.isDotted {
            let dotRect = CGRect(
                x: headRect.maxX + metrics.lineSpacing * 0.35,
                y: y - metrics.lineSpacing * 0.12,
                width: metrics.lineSpacing * 0.24,
                height: metrics.lineSpacing * 0.24
            )
            context.fill(Path(ellipseIn: dotRect), with: .color(.primary))
        }
    }

    private func drawRest(
        event: NoteEvent,
        x: CGFloat,
        context: inout GraphicsContext,
        metrics: StaffMetrics
    ) {
        let symbol: String
        switch event.duration {
        case .half: symbol = "𝄼"
        case .quarter: symbol = "𝄽"
        case .eighth: symbol = "𝄾"
        case .sixteenth: symbol = "𝄿"
        }

        let rest = Text(symbol)
            .font(.system(size: metrics.lineSpacing * 2.2, weight: .regular))
            .foregroundColor(.primary)
        context.draw(
            rest,
            at: CGPoint(x: x, y: metrics.staffCenterY),
            anchor: .center
        )

        if event.isDotted {
            let dotRect = CGRect(
                x: x + metrics.lineSpacing * 0.65,
                y: metrics.staffCenterY - metrics.lineSpacing * 0.1,
                width: metrics.lineSpacing * 0.24,
                height: metrics.lineSpacing * 0.24
            )
            context.fill(Path(ellipseIn: dotRect), with: .color(.primary))
        }
    }

    private func drawLedgerLines(
        for pitch: Pitch,
        x: CGFloat,
        context: inout GraphicsContext,
        metrics: StaffMetrics
    ) {
        let offset = pitch.staffOffset
        let ledgerOffsets: [Int]

        if offset < 0 {
            ledgerOffsets = stride(from: -2, through: offset - (offset % 2), by: -2).map { $0 }
        } else if offset > 8 {
            ledgerOffsets = stride(from: 10, through: offset - (offset % 2), by: 2).map { $0 }
        } else {
            ledgerOffsets = []
        }

        for ledgerOffset in ledgerOffsets {
            let y = metrics.y(forStaffOffset: ledgerOffset)
            var line = Path()
            line.move(to: CGPoint(x: x - metrics.lineSpacing * 0.85, y: y))
            line.addLine(to: CGPoint(x: x + metrics.lineSpacing * 0.85, y: y))
            context.stroke(line, with: .color(.primary), lineWidth: 2.0)
        }
    }

    private func drawCursor(
        beat: Double,
        color: Color,
        context: inout GraphicsContext,
        metrics: StaffMetrics
    ) {
        let x = metrics.x(forBeat: beat)
        let cursorRect = CGRect(
            x: x - 1.5,
            y: metrics.topLineY - metrics.lineSpacing * 1.05,
            width: 3,
            height: metrics.lineSpacing * 6.1
        )
        context.fill(
            Path(roundedRect: cursorRect, cornerRadius: 1.5),
            with: .color(color.opacity(0.85))
        )
    }
}

private struct StaffMetrics {
    let size: CGSize
    let measureBeats: Double
    let lineSpacing: CGFloat
    let topLineY: CGFloat
    let staffLeft: CGFloat
    let staffRight: CGFloat
    let clefCenterX: CGFloat
    let noteAreaLeft: CGFloat

    init(size: CGSize, measureBeats: Double) {
        self.size = size
        self.measureBeats = measureBeats

        let verticalSpacing = min(max(size.height / 8.0, 18), 34)
        self.lineSpacing = verticalSpacing
        self.topLineY = size.height / 2 - verticalSpacing * 2
        self.staffLeft = max(14, size.width * 0.018)
        self.staffRight = size.width - max(14, size.width * 0.018)
        self.clefCenterX = staffLeft + verticalSpacing * 2.4
        self.noteAreaLeft = staffLeft + verticalSpacing * 5.0
    }

    var bottomLineY: CGFloat { topLineY + lineSpacing * 4 }
    var staffCenterY: CGFloat { topLineY + lineSpacing * 2 }
    var noteAreaWidth: CGFloat { max(1, staffRight - noteAreaLeft) }

    func x(forBeat beat: Double) -> CGFloat {
        noteAreaLeft + CGFloat(beat / measureBeats) * noteAreaWidth
    }

    func y(forPitch pitch: Pitch) -> CGFloat {
        y(forStaffOffset: pitch.staffOffset)
    }

    func y(forStaffOffset offset: Int) -> CGFloat {
        bottomLineY - CGFloat(offset) * (lineSpacing / 2)
    }

    func pitch(forY y: CGFloat) -> Pitch {
        let rawOffset = Int(round((bottomLineY - y) / (lineSpacing / 2)))
        let clamped = min(max(rawOffset, -5), 13)
        return Pitch(staffOffset: clamped)
    }
}
