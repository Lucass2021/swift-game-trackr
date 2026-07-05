import SwiftUI

struct HomeSectionHeader: View {
    let title: String
    let onViewAll: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: onViewAll) {
                Text("View All")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appPrimary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeSectionHeader(title: "New Releases", onViewAll: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
