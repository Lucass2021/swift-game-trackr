import SwiftUI

struct TermsAcceptanceRow: View {
    @Binding var isAccepted: Bool
    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    isAccepted.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isAccepted ? Color.appPrimary : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(borderColor, lineWidth: 1.5)
                        )
                        .overlay {
                            if isAccepted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.appOnPrimary)
                            }
                        }
                }
                .buttonStyle(.plain)

                Text("I have read and accept the **[Terms of Use](https://github.com/lucianobcorrea/game-trackr-api)** and the **[Privacy Policy](https://github.com/lucianobcorrea/game-trackr-api)**.")
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
    @Previewable @State var isAccepted = false
    TermsAcceptanceRow(isAccepted: $isAccepted)
        .padding()
        .background(Color.appBackground)
}
