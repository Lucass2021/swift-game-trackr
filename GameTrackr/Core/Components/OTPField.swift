import SwiftUI

struct OTPField: View {
    @Binding var code: String
    var length: Int = 6
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0)
                .frame(width: 1, height: 1)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.filter(\.isNumber).prefix(length))
                }

            HStack(spacing: 12) {
                ForEach(0 ..< length, id: \.self) { index in
                    digitBox(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
        .onAppear { isFocused = true }
    }

    private func digitBox(at index: Int) -> some View {
        let chars = Array(code)
        let char = index < chars.count ? String(chars[index]) : ""
        let isActive = isFocused && (index == chars.count || (index == length - 1 && chars.count >= length))

        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurfaceCard)
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.appPrimary : Color.appOutline, lineWidth: isActive ? 2 : 1)
            Text(char)
                .font(.appHeadline(24, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

#Preview {
    @Previewable @State var code = ""
    OTPField(code: $code)
        .padding()
        .background(Color.appBackground)
}
