import SwiftUI
import UIKit

@available(iOS 15.0, *)
final class GradientBorderHostView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemRed.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderMaskLayer.lineWidth = 4
        gradientLayer.mask = borderMaskLayer
        layer.addSublayer(gradientLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unavailable")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        borderMaskLayer.frame = bounds
        borderMaskLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 2, dy: 2),
            cornerRadius: 20
        ).cgPath
        CATransaction.commit()
    }

    func setAnimating(_ shouldAnimate: Bool) {
        let key = "gradient-border.rotation"
        guard shouldAnimate else {
            gradientLayer.removeAnimation(forKey: key)
            return
        }
        guard gradientLayer.animation(forKey: key) == nil else { return }

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 2
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: key)
    }
}

@available(iOS 15.0, *)
struct RotatingGradientBorder: UIViewRepresentable {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let isAnimating: Bool

    func makeUIView(context: Context) -> GradientBorderHostView {
        GradientBorderHostView()
    }

    func updateUIView(_ view: GradientBorderHostView, context: Context) {
        view.setAnimating(isAnimating && !reduceMotion)
    }

    static func dismantleUIView(_ view: GradientBorderHostView, coordinator: Void) {
        view.setAnimating(false)
    }
}
