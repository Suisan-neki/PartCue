import SwiftUI

struct EditorHeaderView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel
    var playback: Bool = false

    var body: some View {
        HStack(spacing: 18) {
            Text(viewModel.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 8)

            if !playback {
                Text(viewModel.currentSelectionLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            timeSignature
            tempo
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var timeSignature: some View {
        VStack(spacing: -5) {
            Text("4")
            Text("4")
        }
        .font(.system(size: 18, weight: .bold, design: .serif))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("4分の4拍子")
    }

    private var tempo: some View {
        HStack(spacing: 7) {
            DurationGlyphView(duration: .quarter)
                .frame(width: 22, height: 36)
            Text("= \(Int(viewModel.bpm))")
                .font(.system(size: 22, weight: .medium, design: .rounded))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("テンポ \(Int(viewModel.bpm))")
    }
}
