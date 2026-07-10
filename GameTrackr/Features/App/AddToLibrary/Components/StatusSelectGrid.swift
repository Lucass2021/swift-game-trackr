import SwiftUI

struct StatusSelectGrid: View {
    @Binding var selection: LibraryStatus

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(LibraryStatus.allCases) { status in
                let isSelected = status == selection
                Button {
                    selection = status
                } label: {
                    Text(status.rawValue)
                        .font(.appLabel(14))
                        .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? Color.appPrimary : Color.appSurfaceCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: 1)
                        )
                        .shadow(color: isSelected ? Color.appPrimary.opacity(0.4) : .clear, radius: 14, y: 2)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: LibraryStatus = .playing
    StatusSelectGrid(selection: $selection)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
