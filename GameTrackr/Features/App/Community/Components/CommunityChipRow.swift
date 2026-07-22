import SwiftUI

struct CommunityChipRow: View {
    let titles: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(titles, id: \.self) { title in
                    chip(title)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(_ title: String) -> some View {
        let isSelected = selection == title
        return Button {
            selection = title
        } label: {
            Text(title)
                .font(.appLabel(14))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(Capsule().fill(isSelected ? Color.appPrimary : Color.clear))
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection = "All"
    CommunityChipRow(titles: CommunityMockData.categories, selection: $selection)
        .padding(.vertical)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
