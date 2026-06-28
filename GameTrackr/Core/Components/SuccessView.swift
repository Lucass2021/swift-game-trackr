import SwiftUI

struct SuccessView: View {
    let title: String
    let subtitle: String
    var statusTitle: String? = nil
    var statusValue: String? = nil
    let buttonTitle: String
    let onPrimary: () -> Void

    @State private var remaining = 5

    var body: some View {
        AuthScreenScaffold {
            Spacer(minLength: 0)

            checkBadge
                .staggeredAppear(0)

            Text(title)
                .font(.appHeadline(32, weight: .heavy))
                .foregroundStyle(Color.appPrimary)
                .padding(.top, 28)
                .staggeredAppear(1)

            Text(subtitle)
                .font(.appBody(17))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .staggeredAppear(2)

            if let statusTitle, let statusValue {
                statusCard(statusTitle, statusValue)
                    .padding(.top, 28)
                    .staggeredAppear(3)
            }

            Spacer(minLength: 0)

            VStack(spacing: 14) {
                PrimaryButton(title: buttonTitle, action: onPrimary)

                Text("Redirecting in \(remaining) seconds…")
                    .font(.appLabel(13))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.top, 24)
            .staggeredAppear(4)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            do {
                while remaining > 0 {
                    try await Task.sleep(for: .seconds(1))
                    remaining -= 1
                }
                onPrimary()
            } catch {
            }
        }
    }

    private var checkBadge: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 96))
            .foregroundStyle(Color.appSecondary)
            .shadow(color: Color.appSecondary.opacity(0.4), radius: 24)
    }

    private func statusCard(_ heading: String, _ value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.appSecondary)
                .frame(width: 44, height: 44)
                .background(Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(heading.uppercased())
                    .font(.appLabel(12))
                    .foregroundStyle(Color.appTextSecondary)
                    .tracking(0.5)
                Text(value)
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appTextPrimary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.appSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        SuccessView(
            title: "All set!",
            subtitle: "Your password was changed successfully. You can now sign in with your new password.",
            statusTitle: "Account status",
            statusValue: "Validated and Active",
            buttonTitle: "Back to login",
            onPrimary: {}
        )
    }
    .preferredColorScheme(.dark)
}
