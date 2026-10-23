import SwiftUI

private enum Constants {
    static let counterSize: CGFloat = 12
    static let messageSize: CGFloat = 13
}

struct FormField<Content: View>: View {
    let label: String
    var error: String?
    var hint: String?
    var counter: Int?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                if let counter {
                    Text("\(counter)")
                        .font(.appBody(Constants.counterSize))
                        .foregroundStyle(counter < 0 ? Color.appTertiary : Color.appTextSecondary)
                }
            }

            content

            if let error {
                Text(error)
                    .font(.appBody(Constants.messageSize))
                    .foregroundStyle(Color.appTertiary)
            } else if let hint {
                Text(hint)
                    .font(.appBody(Constants.messageSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        FormField(label: "Bio", error: "Bio must be at most 1000 characters", counter: -12) {
            Text("Field content")
                .foregroundStyle(Color.appTextSecondary)
        }
        FormField(label: "Name", hint: "No spaces — this is how the community is listed.") {
            Text("Field content")
                .foregroundStyle(Color.appTextSecondary)
        }
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
