import SwiftUI

struct ExploreCommunityCard: View {
    let onExplore: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Can't find a game?")
                .font(.appHeadline(20, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)

            Text("Try refining your filters or browse the community collections.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: onExplore) {
                Text("Explore Community")
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.appPrimary))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.appSurfaceCard)

                AppIconView(icon: .brand, size: 96)
                    .foregroundStyle(Color.appPrimary.opacity(0.06))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, 24)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        }
    }
}

#Preview {
    ExploreCommunityCard(onExplore: {})
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
