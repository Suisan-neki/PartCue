import SwiftUI

struct PlaybackView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                EditorHeaderView(viewModel: viewModel, playback: true)
                    .frame(height: min(max(proxy.size.height * 0.15, 52), 66))

                rehearsalModePicker
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(uiColor: .secondarySystemBackground))

                TrackStaffRow(
                    role: .cue,
                    instrumentName: viewModel.cueInstrumentName,
                    events: viewModel.cueEvents,
                    currentBeat: viewModel.cueCurrentBeat,
                    measureBeats: viewModel.measureBeats,
                    playbackBeat: viewModel.playbackBeat,
                    activeEventID: viewModel.activeCueEventID,
                    isSelected: viewModel.rehearsalMode != .together,
                    isInteractive: false
                )

                Divider()

                TrackStaffRow(
                    role: .player,
                    instrumentName: viewModel.playerInstrumentName,
                    events: viewModel.playerEvents,
                    currentBeat: viewModel.playerCurrentBeat,
                    measureBeats: viewModel.measureBeats,
                    playbackBeat: viewModel.playbackBeat,
                    activeEventID: viewModel.activePlayerEventID,
                    isSelected: viewModel.rehearsalMode == .rehearse,
                    isInteractive: false
                )
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    if viewModel.detailedFeedbackUnlocked {
                        detailedFeedbackBadge
                    }
                    if viewModel.shouldOfferIntermission {
                        intermissionPrompt
                    }
                    playbackControls
                }
                .padding(.bottom, 12)
            }
            .background(Color(uiColor: .systemBackground))
        }
    }

    private var rehearsalModePicker: some View {
        HStack(spacing: 8) {
            ForEach(RehearsalMode.allCases) { mode in
                Button {
                    viewModel.startPlayback(mode: mode)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.systemImage)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(mode.title)
                                .font(.caption.weight(.bold))
                            Text(mode.subtitle)
                                .font(.system(size: 9, weight: .medium))
                                .opacity(0.75)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .foregroundStyle(viewModel.rehearsalMode == mode ? Color.white : Color.primary)
                    .background(
                        viewModel.rehearsalMode == mode
                            ? Color.accentColor
                            : Color(uiColor: .systemBackground),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var detailedFeedbackBadge: some View {
        Label(
            "詳細フィードバック解放済み — マイク判定は次の実装",
            systemImage: "waveform.path.ecg"
        )
        .font(.caption.weight(.bold))
        .padding(.horizontal, 13)
        .padding(.vertical, 7)
        .foregroundStyle(Color.accentColor)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var intermissionPrompt: some View {
        Button {
            viewModel.presentIntermission()
        } label: {
            Label(
                "3回のセット完了 — インターミッション",
                systemImage: "sparkles.tv"
            )
            .font(.caption.weight(.bold))
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .foregroundStyle(Color.primary)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.accentColor.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("練習を止めた状態で広告付き休憩を選べます")
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