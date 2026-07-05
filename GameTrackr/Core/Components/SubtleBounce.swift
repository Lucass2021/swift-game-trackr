import SwiftUI

struct SubtleBounce: ViewModifier {
    var distance: CGFloat = 7
    var duration: Double = 1.3

    func body(content: Content) -> some View {
        content.phaseAnimator([false, true]) { view, lifted in
            view.offset(y: lifted ? -distance : 0)
        } animation: { _ in
            .easeInOut(duration: duration)
        }
    }
}

extension View {
    func subtleBounce(distance: CGFloat = 7, duration: Double = 1.3) -> some View {
        modifier(SubtleBounce(distance: distance, duration: duration))
    }
}
