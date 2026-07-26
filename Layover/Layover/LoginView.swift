import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.colorScheme) private var systemScheme

    private var palette: Palette {
        .of(systemScheme == .dark ? .dark : .light)
    }

    var body: some View {
        let p = palette
        ZStack {
            p.bg.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 10) {
                    (Text("Layover").foregroundStyle(p.ink)
                        + Text(".").foregroundStyle(p.accent))
                        .font(.hanken(30, .heavy))
                        .tracking(-0.3)
                    Text("Sign in to keep your duty day on this device — and, soon, every device.")
                        .font(.hanken(14))
                        .foregroundStyle(p.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                SignInWithAppleButton(.signIn) { request in
                    auth.startSignInWithAppleRequest(request)
                } onCompletion: { result in
                    auth.handleSignInWithApple(result: result)
                }
                .signInWithAppleButtonStyle(systemScheme == .dark ? .white : .black)
                .frame(height: 50)
                .clipShape(Capsule())
                .padding(.horizontal, 32)

                if let message = auth.errorMessage {
                    Text(message)
                        .font(.hanken(12))
                        .foregroundStyle(p.downRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()
                Spacer()
            }
        }
    }
}
