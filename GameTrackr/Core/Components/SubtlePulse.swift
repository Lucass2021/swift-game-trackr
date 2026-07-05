import SwiftUI

struct SubtlePulse: ViewModifier {
    var maxScale: CGFloat = 1.08
    var minOpacity: CGFloat = 0.82
    var duration: Double = 1.1

    func body(content: Content) -> some View {
        content.phaseAnimator([false, true]) { view, active in
            view
                .scaleEffect(active ? maxScale : 1)
                .opacity(active ? minOpacity : 1)
        } animation: { _ in
            .easeInOut(duration: duration)
        }
    }
}

extension View {
    func subtlePulse(maxScale: CGFloat = 1.08, minOpacity: CGFloat = 0.82, duration: Double = 1.1) -> some View {
        modifier(SubtlePulse(maxScale: maxScale, minOpacity: minOpacity, duration: duration))
    }
}
