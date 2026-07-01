import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Button {
                if let action { action() } else { dismiss() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }
}

#Preview {
    BackButton()
        .padding()
        .background(Color.appBackground)
}
