import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void

    @State private var iconScale = 0.5
    @State private var iconOpacity = 0.0
    @State private var titleOpacity = 0.0
    @State private var subtitleOpacity = 0.0
    @State private var subtitleOffset = 15.0
    @State private var progressOpacity = 0.0
    @State private var progress = 0.0 // 0 → 1

    private let trackWidth: CGFloat = 220

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.appSurfaceCard)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.appOutline, lineWidth: 0.6)
                        )

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                Text("GameTrackr")
                    .font(.appHeadline(34))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 32)
                    .opacity(titleOpacity)

                Text("TRACK · RATE · CONQUER")
                    .font(.appLabel(12))
                    .tracking(3)
                    .foregroundStyle(Color.appSecondary)
                    .padding(.top, 12)
                    .opacity(subtitleOpacity)
                    .offset(y: subtitleOffset)
            }

            VStack(spacing: 20) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appSurfaceCard)
                        .frame(width: trackWidth, height: 4)

                    Capsule()
                        .fill(Color.appPrimary)
                        .frame(width: trackWidth * progress, height: 4)
                }

                Text("LOADING")
                    .font(.appLabel(11))
                    .tracking(3)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .opacity(progressOpacity)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 64)
        }
        .onAppear(perform: runAnimation)
    }

    private func runAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
            iconScale = 1
            iconOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            subtitleOpacity = 1
            subtitleOffset = 0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            progressOpacity = 1
        }
        withAnimation(.easeInOut(duration: 1.8).delay(1.1)) {
            progress = 1
        } completion: {
            onFinish()
        }
    }
}

#Preview {
    SplashView {}
}
