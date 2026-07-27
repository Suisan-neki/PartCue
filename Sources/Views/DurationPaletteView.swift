import SwiftUI

struct DurationPaletteView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(NoteDuration.allCases) { duration in
                Button {
                    viewModel.selectDuration(duration)
                } label: {
                    VStack(spacing: 2) {
                        DurationGlyphView(
                            duration: duration,
                            color: viewModel.selectedDuration == duration ? .white : .primary
                        )
                        .frame(width: 27, height: 38)

                        Text(duration.shortLabel)
                            .font(.caption2.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(viewModel.selectedDuration == duration ? .white : .primary)
                    .background(
                        viewModel.selectedDuration == duration
                            ? Color.accentColor
                            : Color.clear
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(duration.accessibilityLabel)

                if duration != NoteDuration.allCases.last {
                    Divider()
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .overlay(alignment: .trailing) {
            Divider()
        }
    }
}
