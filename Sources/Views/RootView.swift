import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = ScoreEditorViewModel()

    var body: some View {
        GeometryReader { proxy in
            Group {
                if proxy.size.width < proxy.size.height {
                    RotationHintView()
                } else {
                    switch viewModel.mode {
                    case .editing:
                        ScoreEditorView(viewModel: viewModel)
                            .transition(.opacity.combined(with: .scale(scale: 0.985)))
                    case .playback:
                        PlaybackView(viewModel: viewModel)
                            .transition(.opacity.combined(with: .scale(scale: 1.015)))
                    case .intermission:
                        IntermissionView(viewModel: viewModel)
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .animation(.easeInOut(duration: 0.22), value: viewModel.mode)
            .alert(
                "入力できません",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { presented in
                        if !presented {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}