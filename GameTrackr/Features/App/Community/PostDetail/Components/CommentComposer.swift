import SwiftUI

private enum Constants {
    static let reactionSize: CGFloat = 22
    static let avatarSize: CGFloat = 34
    static let fieldTextSize: CGFloat = 15
    static let fieldLineLimit = 1 ... 4
    static let sendButtonSize: CGFloat = 44
    static let sendIconSize: CGFloat = 20
    static let disabledAlpha = 0.4
    static let borderWidth: CGFloat = 1
}

struct CommentComposer: View {
    @Binding var draft: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void = {}

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(CommunityOptions.quickReactions, id: \.self) { reaction in
                        Button {
                            draft += reaction
                        } label: {
                            Text(reaction)
                                .font(.system(size: Constants.reactionSize))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }

            HStack(spacing: Spacing.sm) {
                CommunityAvatar(start: .coverCyanStart, end: .coverCyanEnd, size: Constants.avatarSize)

                TextField(
                    "",
                    text: $draft,
                    prompt: Text("Add a comment…").foregroundStyle(Color.appTextSecondary),
                    axis: .vertical
                )
                .font(.appBody(Constants.fieldTextSize))
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .lineLimit(Constants.fieldLineLimit)
                .focused(isFocused)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Capsule().fill(Color.appBackground))
                .overlay(Capsule().stroke(Color.appOutline, lineWidth: Constants.borderWidth))

                Button(action: onSubmit) {
                    AppIconView(icon: .send, size: Constants.sendIconSize)
                        .foregroundStyle(Color.appOnPrimary)
                        .frame(width: Constants.sendButtonSize, height: Constants.sendButtonSize)
                        .background(Circle()
                            .fill(canSend ? Color.appPrimary : Color.appPrimary.opacity(Constants.disabledAlpha)))
                        .contentShape(Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(!canSend)
                .accessibilityLabel("Send comment")
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
        .background(Color.appSurfaceCard)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: Constants.borderWidth)
        }
    }
}

#Preview {
    @Previewable @State var draft = "Great post!"
    @Previewable @FocusState var isFocused: Bool
    CommentComposer(draft: $draft, isFocused: $isFocused)
        .preferredColorScheme(.dark)
}
