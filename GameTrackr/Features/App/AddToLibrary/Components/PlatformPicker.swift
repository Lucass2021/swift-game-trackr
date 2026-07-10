import SwiftUI

struct PlatformPicker: View {
    @Binding var selection: String
    let options: [String]

    @State private var isOpen = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { isOpen.toggle() }
        } label: {
            HStack {
                Text(selection)
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                AppIconView(icon: .caretDown, size: 16)
                    .foregroundStyle(Color.appTextSecondary)
                    .rotationEffect(.degrees(isOpen ? 180 : 0))
            }
            .fieldBox()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topLeading) {
            if isOpen {
                dropdown
                    .offset(y: 58)
                    .zIndex(20)
            }
        }
        .zIndex(isOpen ? 20 : 0)
    }

    private var dropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    selection = option
                    withAnimation(.easeInOut(duration: 0.15)) { isOpen = false }
                } label: {
                    Text(option)
                        .font(.appBody(16))
                        .foregroundStyle(option == selection ? Color.appPrimary : Color.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < options.count - 1 {
                    Divider().overlay(Color.appOutline)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
    }
}
