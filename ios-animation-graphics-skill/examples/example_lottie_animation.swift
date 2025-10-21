import SwiftUI
import Lottie

struct LottieAnimationView: View {
    @State private var isPlaying = false
    @State private var animationView: LottieAnimationView?
    
    var body: some View {
        VStack(spacing: 20) {
            // Lottie Animation Container
            ZStack {
                Color.gray.opacity(0.1)
                    .frame(height: 200)
                    .cornerRadius(10)
                
                if let animationView = animationView {
                    LottieView(animationView: animationView)
                        .frame(height: 200)
                } else {
                    Text("Loading animation...")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    playAnimation()
                }) {
                    Label("Play", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isPlaying)
                
                Button(action: {
                    stopAnimation()
                }) {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .disabled(!isPlaying)
            }
        }
        .padding()
        .onAppear {
            loadAnimation()
        }
    }
    
    private func loadAnimation() {
        // Load animation from bundle (you would add the JSON file to your project)
        if let animation = LottieAnimation.named("celebration") {
            animationView = LottieAnimationView(animation: animation)
            animationView?.loopMode = .playOnce
        }
    }
    
    private func playAnimation() {
        isPlaying = true
        animationView?.play { _ in
            isPlaying = false
        }
    }
    
    private func stopAnimation() {
        animationView?.stop()
        isPlaying = false
    }
}

// UIViewRepresentable wrapper for Lottie
struct LottieView: UIViewRepresentable {
    let animationView: LottieAnimationView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}