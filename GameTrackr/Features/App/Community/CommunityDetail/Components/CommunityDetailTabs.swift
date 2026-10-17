import SwiftUI

private enum Constants {
    static let dividerThickness: CGFloat = 1
    static let indicatorHeight: CGFloat = 2
    static let labelSize: CGFloat = 15
}

struct CommunityDetailTabs: View {
    @Binding var selection: CommunityDetailTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CommunityDetailTab.allCases) { tab in
                tabButton(tab)
            }

            Spacer(minLength: 0)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: Constants.dividerThickness)
        }
        .padding(.horizontal, Spacing.lg)
    }

    private func tabButton(_ tab: CommunityDetailTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.snappy(duration: 0.2)) {
                selection = tab
            }
        } label: {
            Text(tab.rawValue)
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                        .frame(height: Constants.indicatorHeight)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection: CommunityDetailTab = .posts
    CommunityDetailTabs(selection: $selection)
        .padding(.vertical)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
