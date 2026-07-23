import SwiftUI

struct CommunityPickerField: View {
    @Binding var selection: Community?
    let options: [Community]
    var isLocked = false

    @State private var isOpen = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { isOpen.toggle() }
        } label: {
            HStack(spacing: 12) {
                if let selection {
                    CommunityIcon(start: selection.iconStart, end: selection.iconEnd, size: 28, cornerRadius: 8)

                    Text(selection.name)
                        .font(.appBody(16))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                } else {
                    Text("Choose a community")
                        .font(.appBody(16))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 8)

                if !isLocked {
                    AppIconView(icon: .caretDown, size: 16)
                        .foregroundStyle(Color.appTextSecondary)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
            }
            .fieldBox()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
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
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                Button {
                    selection = option
                    withAnimation(.easeInOut(duration: 0.15)) { isOpen = false }
                } label: {
                    HStack(spacing: 12) {
                        CommunityIcon(start: option.iconStart, end: option.iconEnd, size: 26, cornerRadius: 8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.name)
                                .font(.appBody(16))
                                .foregroundStyle(option.id == selection?.id ? Color.appPrimary : Color.appTextPrimary)
                                .lineLimit(1)

                            Text(option.subtitle)
                                .font(.appBody(12))
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
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

#Preview {
    CommunityPickerField(
        selection: .constant(nil),
        options: CommunityMockData.all.filter(\.isJoined)
    )
    .padding(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
