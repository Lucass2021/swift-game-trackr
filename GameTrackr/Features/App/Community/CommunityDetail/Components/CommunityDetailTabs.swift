import SwiftUI

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
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
    }

    private func tabButton(_ tab: CommunityDetailTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.snappy(duration: 0.2)) {
                selection = tab
            }
        } label: {
            Text(tab.rawValue)
                .font(.appLabel(15))
                .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                        .frame(height: 2)
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
