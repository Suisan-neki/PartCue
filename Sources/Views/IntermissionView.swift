import SwiftUI

struct IntermissionView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel
    @State private var isShowingAdPreview = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.14),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("INTERMISSION")
                        .font(.caption.weight(.black))
                        .tracking(3)
                        .foregroundStyle(Color.accentColor)

                    Text("3回の練習セットが\n終わりました")
                        .font(.system(size: 31, weight: .bold, design: .rounded))

                    Text("広告は入力中や再生中には出しません。区切りで一度止まり、見るかどうかを自分で選べます。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        Label("自動表示なし", systemImage: "hand.raised.fill")
                        Label("1セット1回まで", systemImage: "number.circle")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 14) {
                    VStack(spacing: 9) {
                        Image(systemName: "sparkles.tv")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(Color.accentColor)

                        Text("Sponsored Rest")
                            .font(.title3.weight(.bold))

                        Text("動画広告を見ると、このセッションの詳細フィードバックを開く設計です。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text("TEST AD UX PREVIEW")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(.orange)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))

                    Button {
                        isShowingAdPreview = true
                    } label: {
                        Label("広告体験をプレビュー", systemImage: "play.rectangle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("広告を見ずに続ける") {
                        viewModel.skipIntermission()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 360)
            }
            .padding(.horizontal, 42)
            .padding(.vertical, 28)

            if isShowingAdPreview {
                adPreview
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isShowingAdPreview)
    }

    private var adPreview: some View {
        ZStack {
            Color.black.opacity(0.76)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("TEST AD PLACEHOLDER")
                    .font(.caption.weight(.black))
                    .tracking(2)
                    .foregroundStyle(.yellow)

                Image(systemName: "music.note.house.fill")
                    .font(.system(size: 56))

                Text("ここにRevenueCat Adsで追跡する\nRewarded Adを表示")
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("本番ではAdMobのテスト広告から接続し、完了時だけセッション内報酬を付与します。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("プレビューを完了") {
                    isShowingAdPreview = false
                    viewModel.completeSponsoredIntermission()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(30)
            .frame(maxWidth: 460)
            .foregroundStyle(.white)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 26))
            .shadow(radius: 30)
        }
    }
}