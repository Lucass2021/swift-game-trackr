import CoreText
import SwiftUI

enum AppFonts {
    private static var didRegister = false

    static func register() {
        guard !didRegister else { return }
        didRegister = true

        for ext in ["ttf", "otf"] {
            let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? []
            for url in urls {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}

extension Font {
    static func appHeadline(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("Sora", size: size).weight(weight)
    }

    static func appBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Inter", size: size).weight(weight)
    }

    static func appLabel(_ size: CGFloat = 16, weight: Font.Weight = .semibold) -> Font {
        .custom("Inter", size: size).weight(weight)
    }
}
