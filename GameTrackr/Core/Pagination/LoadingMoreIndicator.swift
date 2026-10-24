import SwiftUI

struct LoadingMoreIndicator: View {
    var body: some View {
        ProgressView()
            .tint(Color.appTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }
}

#Preview {
    LoadingMoreIndicator()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
