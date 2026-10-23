import SwiftUI

private enum Constants {
    static let counterSize: CGFloat = 12
    static let errorSize: CGFloat = 13
}

struct EditProfileField<Content: View>: View {
    let label: String
    var error: String?
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
                    .font(.appBody(Constants.errorSize))
                    .foregroundStyle(Color.appTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EditProfileField(label: "Bio", error: "Bio must be at most 1000 characters", counter: -12) {
        Text("Field content")
            .foregroundStyle(Color.appTextSecondary)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
