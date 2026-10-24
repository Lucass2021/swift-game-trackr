import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 26
    static let nameSize: CGFloat = 16
    static let subtitleSize: CGFloat = 12
    static let messageSize: CGFloat = 14
    static let borderWidth: CGFloat = 1
    static let shadowOpacity = 0.4
    static let shadowRadius: CGFloat = 16
    static let shadowOffset: CGFloat = 8
}

struct CommunityPickerOptions: View {
    let selection: Community?
    let options: [Community]
    let isLoading: Bool
    let isFailed: Bool
    let onSelect: (Community) -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isFailed {
                failedRow
            } else if isLoading {
                messageRow("Loading your communities…")
            } else if options.isEmpty {
                messageRow("You haven't joined any communities yet.")
            } else {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    optionRow(option)
                    if index < options.count - 1 {
                        Divider().overlay(Color.appOutline)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
        .shadow(
            color: .black.opacity(Constants.shadowOpacity),
            radius: Constants.shadowRadius,
            y: Constants.shadowOffset
        )
    }

    private func optionRow(_ option: Community) -> some View {
        Button {
            onSelect(option)
        } label: {
            HStack(spacing: Spacing.sm) {
                CommunityIcon(
                    start: option.iconStart,
                    end: option.iconEnd,
                    size: Constants.iconSize,
                    cornerRadius: Radius.sm
                )

                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(option.name)
                        .font(.appBody(Constants.nameSize))
                        .foregroundStyle(option.id == selection?.id ? Color.appPrimary : Color.appTextPrimary)
                        .lineLimit(1)

                    Text(option.subtitle)
                        .font(.appBody(Constants.subtitleSize))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func messageRow(_ text: String) -> some View {
        Text(text)
            .font(.appBody(Constants.messageSize))
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.md)
    }

    private var failedRow: some View {
        HStack(spacing: Spacing.xs) {
            Text("Couldn't load your communities.")
                .font(.appBody(Constants.messageSize))
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Try again", action: onRetry)
                .font(.appLabel(Constants.messageSize))
                .foregroundStyle(Color.appPrimary)
                .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.md)
    }
}

#Preview {
    CommunityPickerOptions(
        selection: nil,
        options: CommunityMockData.all.filter(\.isJoined),
        isLoading: false,
        isFailed: false,
        onSelect: { _ in },
        onRetry: {}
    )
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

#Preview("Failed") {
    CommunityPickerOptions(
        selection: nil,
        options: [],
        isLoading: false,
        isFailed: true,
        onSelect: { _ in },
        onRetry: {}
    )
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
