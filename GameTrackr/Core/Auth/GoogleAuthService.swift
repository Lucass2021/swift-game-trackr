import AuthenticationServices
import SwiftUI

enum GoogleAuthError: LocalizedError {
    case cancelled
    case missingToken
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            nil
        case .missingToken:
            "Google didn't return a session. Try again."
        case let .failed(message):
            message
        }
    }
}

@MainActor
protocol GoogleAuthenticating {
    func signIn() async throws -> String
}

@MainActor
final class GoogleAuthService: NSObject, GoogleAuthenticating {
    static let shared = GoogleAuthService()

    static let callbackScheme = "gametrackr"

    private var session: ASWebAuthenticationSession?

    func signIn() async throws -> String {
        guard let url = URL(string: "\(Config.baseURL)/auth/google/redirect?platform=mobile") else {
            throw GoogleAuthError.failed("Invalid sign-in URL.")
        }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: Self.callbackScheme
            ) { callbackURL, error in
                if let error = error as? ASWebAuthenticationSessionError,
                   error.code == .canceledLogin
                {
                    continuation.resume(throwing: GoogleAuthError.cancelled)
                    return
                }

                if let error {
                    continuation.resume(throwing: GoogleAuthError.failed(error.localizedDescription))
                    return
                }

                guard let token = callbackURL.flatMap(Self.token(from:)) else {
                    continuation.resume(throwing: GoogleAuthError.missingToken)
                    return
                }

                continuation.resume(returning: token)
            }

            session.presentationContextProvider = self
            self.session = session

            guard session.start() else {
                continuation.resume(throwing: GoogleAuthError.failed("Couldn't open the Google sign-in page."))
                return
            }
        }
    }

    private static func token(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "token" }?
            .value
    }
}

extension GoogleAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)

        return windows.first { $0.isKeyWindow }
            ?? windows.first
            ?? ASPresentationAnchor(frame: .zero)
    }
}
