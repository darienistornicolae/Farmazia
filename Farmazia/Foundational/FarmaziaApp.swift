import SwiftUI

@main
struct FarmaziaApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  private let container = DependencyContainer()

  var body: some Scene {
    WindowGroup {
      ContentView(container: container)
        .environmentObject(container.makeDataManager())
        .tint(.green)
    }
  }
}
