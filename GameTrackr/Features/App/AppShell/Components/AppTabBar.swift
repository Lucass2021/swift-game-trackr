import SwiftUI

struct AppTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabItem(tab)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(
            Color.appBackground
                .overlay(
                    Rectangle()
                        .fill(Color.appOutline)
                        .frame(height: 1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: .medium))
                Text(tab.title)
                    .font(.appLabel(12))
            }
            .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection: AppTab = .home
    VStack {
        Spacer()
        AppTabBar(selection: $selection)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
