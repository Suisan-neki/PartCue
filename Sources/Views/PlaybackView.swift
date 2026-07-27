import SwiftUI

struct PlaybackView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                EditorHeaderView(viewModel: viewModel, playback: true)
                    .frame(height: min(max(proxy.size.height * 0.18, 58), 78))

                StaffView(
                    events: viewModel.events,
                    currentBeat: viewModel.currentBeat,
                    measureBeats: viewModel.measureBeats,
                    playbackBeat: viewModel.playbackBeat,
                    activeEventID: viewModel.activePlaybackEventID,
                    isInteractive: false,
                    onPitchTapped: nil
                )
                .overlay(alignment: .bottom) {
                    playbackControls
                        .padding(.bottom, 14)
                }
            }
            .background(Color(uiColor: .systemBackground))
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 10) {
            Button {
                if viewModel.isPlaying {
                    viewModel.stopPlayback()
                } else {
                    viewModel.startPlayback()
                }
            } label: {
                Label(
                    viewModel.isPlaying ? "停止" : "再生",
                    systemImage: viewModel.isPlaying ? "stop.fill" : "play.fill"
                )
            }

            Button {
                viewModel.startPlayback()
            } label: {
                Label("もう一度", systemImage: "arrow.counterclockwise")
            }

            Button {
                viewModel.returnToEditing()
            } label: {
                Label("編集", systemImage: "pencil")
            }
        }
        .font(.subheadline.weight(.semibold))
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(8)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.10), radius: 12, y: 4)
    }
}
