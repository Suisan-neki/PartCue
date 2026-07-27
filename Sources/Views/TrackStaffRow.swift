import SwiftUI

struct TrackStaffRow: View {
    let role: TrackRole
    let instrumentName: String
    let events: [NoteEvent]
    let currentBeat: Double
    let measureBeats: Double
    var playbackBeat: Double?
    var activeEventID: UUID?
    var isSelected: Bool
    var isInteractive: Bool
    var onSelect: (() -> Void)?
    var onPitchTapped: ((Pitch) -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            Button {
                onSelect?()
            } label: {
                VStack(spacing: 3) {
                    Text(role.shortLabel)
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                    Text(instrumentName)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemBackground))
            }
            .buttonStyle(.plain)
            .frame(width: 76)
            .disabled(!isInteractive)

            StaffView(
                events: events,
                currentBeat: currentBeat,
                measureBeats: measureBeats,
                playbackBeat: playbackBeat,
                activeEventID: activeEventID,
                isInteractive: isInteractive,
                onPitchTapped: { pitch in
                    onSelect?()
                    onPitchTapped?(pitch)
                }
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                .padding(3)
                .allowsHitTesting(false)
        }
        .background(
            isSelected
                ? Color.accentColor.opacity(0.045)
                : Color(uiColor: .systemBackground)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(role.displayName) \(instrumentName)")
    }
}