import SwiftUI

/// Unicode音符へ依存せず、音価を簡易描画する。
struct DurationGlyphView: View {
    let duration: NoteDuration
    var color: Color = .primary

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.44, y: size.height * 0.66)
            let headRect = CGRect(
                x: center.x - size.width * 0.16,
                y: center.y - size.height * 0.10,
                width: size.width * 0.32,
                height: size.height * 0.20
            )

            let headPath = Path(ellipseIn: headRect)
            if duration.usesOpenNotehead {
                context.stroke(headPath, with: .color(color), lineWidth: 2.4)
            } else {
                context.fill(headPath, with: .color(color))
            }

            let stemX = headRect.maxX - 1
            let stemTop = size.height * 0.16
            var stem = Path()
            stem.move(to: CGPoint(x: stemX, y: center.y))
            stem.addLine(to: CGPoint(x: stemX, y: stemTop))
            context.stroke(stem, with: .color(color), lineWidth: 2.2)

            for flagIndex in 0..<duration.flagCount {
                let offset = CGFloat(flagIndex) * size.height * 0.13
                var flag = Path()
                flag.move(to: CGPoint(x: stemX, y: stemTop + offset))
                flag.addCurve(
                    to: CGPoint(x: stemX + size.width * 0.25, y: stemTop + size.height * 0.22 + offset),
                    control1: CGPoint(x: stemX + size.width * 0.18, y: stemTop + size.height * 0.03 + offset),
                    control2: CGPoint(x: stemX + size.width * 0.26, y: stemTop + size.height * 0.13 + offset)
                )
                context.stroke(flag, with: .color(color), lineWidth: 2.2)
            }
        }
        .aspectRatio(0.72, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
