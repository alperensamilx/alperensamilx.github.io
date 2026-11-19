# Parked: Firebase Auth scaffold

`AuthService.swift` and `LoginView.swift` were written as the first step toward
real accounts (Sign in with Apple + Firebase Auth), but they `import FirebaseAuth`
/ `import FirebaseCore`, which aren't in the Xcode project yet. Sitting inside
`Layover/Layover/` (the compiled target) they'd break every build until that
setup was done, so they're parked here instead — a sibling folder outside the
`PBXFileSystemSynchronizedRootGroup` path, so Xcode never compiles them from
this location.

## To bring this back

1. Firebase Console: create a project, enable **Sign in with Apple** under
   Authentication, enable Firestore, register the iOS app
   (`com.alperensamil.Layover`), download `GoogleService-Info.plist`.
2. In Xcode: **File → Add Package Dependencies…** →
   `https://github.com/firebase/firebase-ios-sdk` → add the **FirebaseAuth**
   and **FirebaseCore** products.
3. Drag `GoogleService-Info.plist` into the `Layover` target.
4. In Xcode's Signing & Capabilities for the `Layover` target, add the
   **Sign in with Apple** capability (needs the paid Apple Developer Program).
5. Move `AuthService.swift` and `LoginView.swift` back into `Layover/Layover/`.
6. In `LayoverApp.swift`: add `import FirebaseCore`, a
   `@State private var auth = AuthService()`, call `FirebaseApp.configure()`
   in `init()`, and gate `RootView()` behind `auth.state` (showing `LoginView()`
   while signed out) — see the git history for the exact diff
   (commit `588bade`, "Add Firebase Auth + Sign in with Apple scaffold").
7. Optionally re-add the sign-out button to `RootView.swift`'s `TopBar`
   (also in that commit).
