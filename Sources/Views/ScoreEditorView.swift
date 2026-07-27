import SwiftUI

struct ScoreEditorView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                DurationPaletteView(viewModel: viewModel)
                    .frame(width: sideWidth(for: proxy.size))

                VStack(spacing: 0) {
                    EditorHeaderView(viewModel: viewModel)
                        .frame(height: headerHeight(for: proxy.size))

                    StaffView(
                        events: viewModel.events,
                        currentBeat: viewModel.currentBeat,
                        measureBeats: viewModel.measureBeats,
                        playbackBeat: nil,
                        activeEventID: nil,
                        isInteractive: !viewModel.isMeasureComplete,
                        onPitchTapped: { pitch in
                            viewModel.addNote(pitch: pitch)
                        }
                    )
                }

                ModifierPanelView(viewModel: viewModel)
                    .frame(width: modifierWidth(for: proxy.size))
            }
            .background(Color(uiColor: .systemBackground))
        }
    }

    private func sideWidth(for size: CGSize) -> CGFloat {
        min(max(size.width * 0.105, 82), 112)
    }

    private func modifierWidth(for size: CGSize) -> CGFloat {
        min(max(size.width * 0.125, 104), 136)
    }

    private func headerHeight(for size: CGSize) -> CGFloat {
        min(max(size.height * 0.18, 58), 78)
    }
}
