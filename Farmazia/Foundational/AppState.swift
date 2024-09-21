import Foundation

class AppState: ObservableObject {
  @Published var hasCompletedOnboarding: Bool
  @Published var isLoggedIn: Bool
  @Published var isFirestoreReady: Bool

  init() {
    self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    self.isLoggedIn = false
    self.isFirestoreReady = false
  }
}
