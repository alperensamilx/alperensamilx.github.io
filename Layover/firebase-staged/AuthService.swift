import SwiftUI
import Observation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

// Wraps Firebase Auth + the Sign in with Apple flow. Apple requires a random
// nonce, hashed with SHA256, sent with the authorization request; the raw
// nonce then goes to Firebase alongside the returned identity token so
// Firebase can verify the request wasn't replayed.
@Observable
final class AuthService: NSObject {
    enum State {
        case signedOut
        case signedIn(uid: String)
    }

    var state: State = .signedOut
    var errorMessage: String?

    private var currentNonce: String?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    override init() {
        super.init()
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.state = user.map { .signedIn(uid: $0.uid) } ?? .signedOut
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName]
        request.nonce = Self.sha256(nonce)
    }

    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription

        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unexpected credential type from Apple."
                return
            }
            guard let nonce = currentNonce else {
                errorMessage = "No sign-in request is in progress."
                return
            }
            guard let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Apple didn't return an identity token."
                return
            }

            let firebaseCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idToken,
                rawNonce: nonce
            )

            Task { @MainActor in
                do {
                    try await Auth.auth().signIn(with: firebaseCredential)
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private static func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(status == errSecSuccess, "Unable to generate a secure nonce (OSStatus \(status)).")
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
