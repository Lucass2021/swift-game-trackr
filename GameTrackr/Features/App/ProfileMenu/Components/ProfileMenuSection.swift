import SwiftUI

struct ProfileMenuSection: View {
    let items: [ProfileMenuItem]
    let onItemSelect: (ProfileMenuItem) -> Void

    var body: some View {
        GroupedSection(title: nil) {
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                GroupedNavRow(icon: item.icon, title: item.title) { onItemSelect(item) }
                if index < items.count - 1 {
                    GroupedDivider()
                }
            }
        }
    }
}

#Preview {
    ProfileMenuSection(items: ProfileMenuItem.allCases) { _ in }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
