import SwiftUI

struct NotificationFilterTabs: View {
    @Binding var selection: NotificationFilter

    var body: some View {
        HStack(spacing: 10) {
            ForEach(NotificationFilter.allCases) { filter in
                chip(filter)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }

    private func chip(_ filter: NotificationFilter) -> some View {
        let isSelected = selection == filter
        return Button {
            selection = filter
        } label: {
            Text(filter.rawValue)
                .font(.appLabel(14))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: 1)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection: NotificationFilter = .all
    NotificationFilterTabs(selection: $selection)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
