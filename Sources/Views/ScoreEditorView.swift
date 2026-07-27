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

                    TrackStaffRow(
                        role: .cue,
                        instrumentName: viewModel.cueInstrumentName,
                        events: viewModel.cueEvents,
                        currentBeat: viewModel.cueCurrentBeat,
                        measureBeats: viewModel.measureBeats,
                        playbackBeat: nil,
                        activeEventID: nil,
                        isSelected: viewModel.selectedTrack == .cue,
                        isInteractive: !viewModel.isTrackComplete(.cue),
                        onSelect: { viewModel.selectTrack(.cue) },
                        onPitchTapped: { pitch in
                            viewModel.addNote(pitch: pitch, to: .cue)
                        }
                    )

                    Divider()

                    TrackStaffRow(
                        role: .player,
                        instrumentName: viewModel.playerInstrumentName,
                        events: viewModel.playerEvents,
                        currentBeat: viewModel.playerCurrentBeat,
                        measureBeats: viewModel.measureBeats,
                        playbackBeat: nil,
                        activeEventID: nil,
                        isSelected: viewModel.selectedTrack == .player,
                        isInteractive: !viewModel.isTrackComplete(.player),
                        onSelect: { viewModel.selectTrack(.player) },
                        onPitchTapped: { pitch in
                            viewModel.addNote(pitch: pitch, to: .player)
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
        min(max(size.width * 0.095, 78), 104)
    }

    private func modifierWidth(for size: CGSize) -> CGFloat {
        min(max(size.width * 0.125, 108), 138)
    }

    private func headerHeight(for size: CGSize) -> CGFloat {
        min(max(size.height * 0.16, 54), 70)
    }
}