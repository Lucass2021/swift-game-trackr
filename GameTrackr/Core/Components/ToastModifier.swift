import SwiftUI

enum ToastStyle {
    case error
    case success

    var color: Color {
        switch self {
        case .error: Color.red.opacity(0.9)
        case .success: Color.green.opacity(0.85)
        }
    }
}

private struct ToastView: View {
    let message: String
    let style: ToastStyle

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(style.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            .padding(.horizontal, 20)
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var message: String?
    let style: ToastStyle

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let message {
                ToastView(message: message, style: style)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut) { self.message = nil }
                        }
                    }
            }
        }
        .animation(.spring(duration: 0.3), value: message)
    }
}

extension View {
    func toast(message: Binding<String?>, style: ToastStyle = .error) -> some View {
        modifier(ToastModifier(message: message, style: style))
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        Text("App content here")
            .foregroundStyle(.white)
    }
    .toast(message: .constant("Something went wrong. Please try again."), style: .error)
}
