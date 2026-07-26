import SwiftUI
import FirebaseCore

@main
struct LayoverApp: App {
    @State private var model = AppModel()
    @State private var auth = AuthService()

    init() {
        AppFonts.register()
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch auth.state {
                case .signedOut:
                    LoginView()
                case .signedIn:
                    RootView()
                }
            }
            .environment(model)
            .environment(auth)
        }
    }
}
