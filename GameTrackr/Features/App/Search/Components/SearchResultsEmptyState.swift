import SwiftUI

struct SearchResultsEmptyState: View {
    let query: String
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppIconView(icon: .search, size: 52)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 120, height: 120)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(0.25), radius: 30)
                .subtleBounce()

            Text("No games found")
                .font(.appHeadline(24, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 26)

            Text(subtitle)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 24)

            Button(action: onClear) {
                Text("Clear search")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appPrimary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 22)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var subtitle: String {
        if query.isEmpty {
            return "No games match this filter. Try a different platform."
        }
        return "No results for \u{201C}\(query)\u{201D}. Try another title or platform."
    }
}

#Preview {
    SearchResultsEmptyState(query: "zelda", onClear: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
