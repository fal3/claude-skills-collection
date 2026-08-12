import Lottie
import SwiftUI

// Requires Lottie 4.3 or newer. The host target must include
// celebration.json (or celebration.lottie) in the intended bundle.
struct CelebrationAnimationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var playbackMode: LottiePlaybackMode = .paused

    var body: some View {
        VStack(spacing: 16) {
            if reduceMotion {
                LottieView(animation: .named("celebration"))
                    .currentProgress(1)
                    .accessibilityHidden(true)
            } else {
                LottieView(animation: .named("celebration"))
                    .playbackMode(playbackMode)
                    .animationDidFinish { _ in
                        playbackMode = .paused
                    }
                    .accessibilityHidden(true)
            }

            Button("Celebrate") {
                guard !reduceMotion else { return }
                playbackMode = .playing(
                    .fromProgress(0, toProgress: 1, loopMode: .playOnce)
                )
            }
            .disabled(reduceMotion)
        }
    }
}
