import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct TimelineWaveformView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = reduceMotion ? 0.0 : elapsed * .pi

            Canvas { context, size in
                let centerY = size.height / 2
                var path = Path()
                path.move(to: CGPoint(x: 0, y: centerY))

                for x in stride(from: 0.0, through: size.width, by: 2.0) {
                    let relativeX = size.width > 0 ? x / size.width : 0
                    let y = centerY + sin(relativeX * .pi * 4 + phase) * 30
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                context.stroke(
                    path,
                    with: .color(.blue),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
            }
        }
        .frame(height: 160)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true)
    }
}
