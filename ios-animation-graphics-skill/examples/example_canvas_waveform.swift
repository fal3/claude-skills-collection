import SwiftUI

struct WaveformView: View {
    @State private var phase = 0.0
    
    var body: some View {
        VStack {
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let centerY = height / 2
                
                // Draw waveform
                var path = Path()
                path.move(to: CGPoint(x: 0, y: centerY))
                
                for x in stride(from: 0, to: width, by: 1) {
                    let relativeX = x / width
                    let y = centerY + sin(relativeX * .pi * 4 + phase) * 30
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
                
                // Draw amplitude bars
                for i in 0..<10 {
                    let barHeight = abs(sin(phase + Double(i) * 0.5)) * 50
                    let barX = width * 0.1 * Double(i + 1)
                    
                    let barRect = CGRect(x: barX - 2, y: centerY - barHeight/2, width: 4, height: barHeight)
                    context.fill(Path(barRect), with: .color(.green.opacity(0.6)))
                }
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Animate Wave") {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase += .pi * 2
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}