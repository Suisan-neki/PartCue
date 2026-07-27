import SwiftUI

struct RotationHintView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "iphone.landscape")
                .font(.system(size: 52, weight: .medium))
                .foregroundStyle(Color.accentColor)
            Text("iPhoneを横向きにしてください")
                .font(.headline)
            Text("PartCueは1小節を広く使うため、横向きで設計しています。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
    }
}
