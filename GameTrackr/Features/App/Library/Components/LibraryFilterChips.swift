import SwiftUI

struct LibraryFilterChips: View {
    @Binding var selection: LibraryStatus?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: "All", isSelected: selection == nil) { selection = nil }

                ForEach(LibraryStatus.allCases) { status in
                    chip(title: status.rawValue, isSelected: selection == status) {
                        selection = status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
    @Previewable @State var selection: LibraryStatus?
    LibraryFilterChips(selection: $selection)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
