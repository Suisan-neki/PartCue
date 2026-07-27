import SwiftUI

struct ModifierPanelView: View {
    @ObservedObject var viewModel: ScoreEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            actionButton(title: "休符", systemImage: "pause.fill") {
                viewModel.addRest()
            }

            Divider()

            ForEach(Accidental.allCases) { accidental in
                symbolToggle(
                    symbol: accidental.symbol,
                    isSelected: viewModel.selectedAccidental == accidental
                ) {
                    viewModel.toggleAccidental(accidental)
                }
            }

            symbolToggle(symbol: "·", label: "付点", isSelected: viewModel.isDotted) {
                viewModel.toggleDotted()
            }

            Spacer(minLength: 4)
            Divider()

            actionButton(title: "戻る", systemImage: "arrow.uturn.backward") {
                viewModel.undo()
            }
            .disabled(viewModel.events.isEmpty)
            .opacity(viewModel.events.isEmpty ? 0.38 : 1)

            Divider()

            actionButton(title: "再生", systemImage: "play.fill", prominent: true) {
                viewModel.enterPlayback()
            }
            .disabled(viewModel.events.isEmpty)
            .opacity(viewModel.events.isEmpty ? 0.38 : 1)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .overlay(alignment: .leading) {
            Divider()
        }
    }

    private func symbolToggle(
        symbol: String,
        label: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(symbol)
                    .font(.system(size: label == nil ? 31 : 34, weight: .regular, design: .serif))
                    .minimumScaleFactor(0.6)
                if let label {
                    Text(label)
                        .font(.caption2.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 47)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(isSelected ? Color.accentColor : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label ?? symbol)
    }

    private func actionButton(
        title: String,
        systemImage: String,
        prominent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(prominent ? .white : .primary)
            .background(prominent ? Color.accentColor : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
