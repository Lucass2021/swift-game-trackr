import SwiftUI

enum PasswordStrength: Int {
    case weak = 1
    case medium = 2
    case strong = 3

    init(password: String) {
        guard !password.isEmpty else {
            self = .weak
            return
        }

        var score = 0
        if password.count >= 6 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil,
           password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters.union(.symbols)) != nil { score += 1 }

        switch score {
        case 0 ... 1: self = .weak
        case 2 ... 3: self = .medium
        default: self = .strong
        }
    }

    var label: String {
        switch self {
        case .weak: "WEAK PASSWORD"
        case .medium: "MEDIUM PASSWORD"
        case .strong: "STRONG PASSWORD"
        }
    }

    var color: Color {
        switch self {
        case .weak: .appTertiary
        case .medium: .appSecondary
        case .strong: .appPrimary
        }
    }
}

struct PasswordStrengthMeter: View {
    let strength: PasswordStrength

    private let segments = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(0 ..< segments, id: \.self) { index in
                    Capsule()
                        .fill(index < strength.rawValue ? strength.color : Color.appOutline)
                        .frame(height: 5)
                }
            }

            Text(strength.label)
                .font(.appLabel(12))
                .foregroundStyle(strength.color)
                .tracking(0.5)
        }
        .animation(.easeOut(duration: 0.2), value: strength)
    }
}

#Preview {
    VStack(spacing: 24) {
        PasswordStrengthMeter(strength: .weak)
        PasswordStrengthMeter(strength: .medium)
        PasswordStrengthMeter(strength: .strong)
    }
    .padding()
    .background(Color.appBackground)
}
