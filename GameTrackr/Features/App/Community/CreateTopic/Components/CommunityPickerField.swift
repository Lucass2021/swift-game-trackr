import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 28
    static let caretSize: CGFloat = 16
    static let textSize: CGFloat = 16
    static let dropdownOffset: CGFloat = 58
    static let openZIndex: Double = 20
    static let caretOpenRotation: Double = 180
}

struct CommunityPickerField: View {
    let selection: Community?
    let options: [Community]
    let onSelect: (Community) -> Void
    var isLocked = false
    var isLoading = false
    var isFailed = false
    var onRetry: () -> Void = {}

    @State private var isOpen = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: Durations.fast)) { isOpen.toggle() }
        } label: {
            HStack(spacing: Spacing.sm) {
                if let selection {
                    CommunityIcon(
                        start: selection.iconStart,
                        end: selection.iconEnd,
                        size: Constants.iconSize,
                        cornerRadius: Radius.sm
                    )

                    Text(selection.name)
                        .font(.appBody(Constants.textSize))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                } else {
                    Text("Choose a community")
                        .font(.appBody(Constants.textSize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: Spacing.xs)

                if !isLocked {
                    AppIconView(icon: .caretDown, size: Constants.caretSize)
                        .foregroundStyle(Color.appTextSecondary)
                        .rotationEffect(.degrees(isOpen ? Constants.caretOpenRotation : 0))
                }
            }
            .fieldBox()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isLocked)
        .accessibilityHint(isLocked ? "" : "Choose a community")
        .overlay(alignment: .topLeading) {
            if isOpen {
                CommunityPickerOptions(
                    selection: selection,
                    options: options,
                    isLoading: isLoading,
                    isFailed: isFailed,
                    onSelect: { option in
                        onSelect(option)
                        withAnimation(.easeInOut(duration: Durations.fast)) { isOpen = false }
                    },
                    onRetry: onRetry
                )
                .offset(y: Constants.dropdownOffset)
                .zIndex(Constants.openZIndex)
            }
        }
        .zIndex(isOpen ? Constants.openZIndex : 0)
    }
}

#Preview {
    CommunityPickerField(selection: nil, options: CommunityMockData.all.filter(\.isJoined), onSelect: { _ in })
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("Locked") {
    CommunityPickerField(selection: CommunityMockData.all.first, options: [], onSelect: { _ in }, isLocked: true)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
