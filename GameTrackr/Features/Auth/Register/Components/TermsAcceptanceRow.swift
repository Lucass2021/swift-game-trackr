import SwiftUI

private enum Constants {
    static let checkboxSize: CGFloat = 24
    static let checkboxBorderWidth: CGFloat = 1.5
    static let checkIconSize: CGFloat = 16
}

struct TermsAcceptanceRow: View {
    let isAccepted: Bool
    var error: String?
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Button(action: onToggle) {
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(isAccepted ? Color.appPrimary : Color.clear)
                        .frame(width: Constants.checkboxSize, height: Constants.checkboxSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .stroke(borderColor, lineWidth: Constants.checkboxBorderWidth)
                        )
                        .overlay {
                            if isAccepted {
                                AppIconView(icon: .check, size: Constants.checkIconSize)
                                    .foregroundStyle(Color.appOnPrimary)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Accept the terms of use and privacy policy")
                .accessibilityAddTraits(isAccepted ? .isSelected : [])

                Text(
                    "I have read and accept the **[Terms of Use](https://github.com/lucianobcorrea/game-trackr-api)** and the **[Privacy Policy](https://github.com/lucianobcorrea/game-trackr-api)**."
                )
                .font(.appBody(14))
                .tint(Color.appSecondary)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            if let error {
                Text(error)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var borderColor: Color {
        if error != nil { return Color.appTertiary }
        return isAccepted ? Color.appPrimary : Color.appOutline
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        TermsAcceptanceRow(isAccepted: true) {}
        TermsAcceptanceRow(isAccepted: false, error: ValidationMessage.termsRequired) {}
    }
    .padding()
    .background(Color.appBackground)
}
