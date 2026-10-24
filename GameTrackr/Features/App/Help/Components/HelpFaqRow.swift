import SwiftUI

struct HelpFaqRow: View {
    let faq: HelpFaq
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: Spacing.sm) {
                    AppIconView(icon: .help, size: Constants.iconSize)
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: GroupedRowMetrics.iconBoxWidth)

                    Text(faq.question)
                        .font(.appLabel(Constants.questionSize))
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    AppIconView(icon: .caretDown, size: Constants.caretSize)
                        .foregroundStyle(Color.appTextSecondary)
                        .rotationEffect(.degrees(isExpanded ? Constants.expandedRotation : 0))
                }
                .padding(Spacing.md)

                if isExpanded {
                    Text(faq.answer)
                        .font(.appBody(Constants.answerSize))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.leading, Constants.answerInset)
                        .padding(.trailing, Spacing.md)
                        .padding(.bottom, Spacing.md)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private enum Constants {
    static let iconSize: CGFloat = 20
    static let caretSize: CGFloat = 14
    static let questionSize: CGFloat = 16
    static let answerSize: CGFloat = 14
    static let expandedRotation: Double = 180
    static let answerInset = Spacing.md + GroupedRowMetrics.iconBoxWidth + Spacing.sm
}

#Preview {
    GroupedSection(title: nil) {
        HelpFaqRow(faq: .addGame, isExpanded: true) {}
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
