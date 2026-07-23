import SwiftUI

@main
struct LayoverApp: App {
    @State private var model = AppModel()

    init() {
        AppFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}
