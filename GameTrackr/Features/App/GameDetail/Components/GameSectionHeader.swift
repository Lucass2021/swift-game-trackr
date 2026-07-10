import SwiftUI

struct GameSectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.appLabel(14))
                        .foregroundStyle(Color.appSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
