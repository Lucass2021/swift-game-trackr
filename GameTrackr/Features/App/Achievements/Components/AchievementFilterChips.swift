import SwiftUI

struct AchievementFilterChips: View {
    @Binding var selection: AchievementFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AchievementFilter.allCases) { filter in
                    chip(filter)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(_ filter: AchievementFilter) -> some View {
        let isSelected = filter == selection

        return Button {
            selection = filter
        } label: {
            Text(filter.title)
                .font(.appLabel(14))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(Capsule().fill(isSelected ? Color.appPrimary : Color.clear))
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selection: AchievementFilter = .all
    AchievementFilterChips(selection: $selection)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
