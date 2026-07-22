import SwiftUI

struct CommentComposer: View {
    @Binding var draft: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(CommunityMockData.quickReactions, id: \.self) { reaction in
                        Button {
                            draft += reaction
                        } label: {
                            Text(reaction)
                                .font(.system(size: 22))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }

            HStack(spacing: 12) {
                CommunityAvatar(start: .coverCyanStart, end: .coverCyanEnd, size: 34)

                TextField(
                    "",
                    text: $draft,
                    prompt: Text("Add a comment…").foregroundStyle(Color.appTextSecondary),
                    axis: .vertical
                )
                .font(.appBody(15))
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .lineLimit(1 ... 4)
                .focused(isFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.appBackground))
                .overlay(Capsule().stroke(Color.appOutline, lineWidth: 1))

                Button {
                    draft = ""
                } label: {
                    AppIconView(icon: .send, size: 20)
                        .foregroundStyle(Color.appOnPrimary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(draft.isEmpty ? Color.appPrimary.opacity(0.4) : Color.appPrimary))
                        .contentShape(Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityLabel("Send comment")
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.appSurfaceCard)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: 1)
        }
    }
}
