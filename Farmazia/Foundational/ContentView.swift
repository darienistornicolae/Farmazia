import SwiftUI

struct ContentView: View {
  @ObservedObject var appState: AppState
  @StateObject private var authViewModel: AuthenticationViewModel
  let container: DependencyContainer

  init(container: DependencyContainer) {
    self.container = container
    self.appState = container.appState
    self._authViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
  }

  var body: some View {
    ZStack {
      if !appState.hasCompletedOnboarding {
        OnboardingFlow(appState: appState)
      } else if !authViewModel.isAuthenticated {
        AuthenticationView(viewModel: authViewModel)
      } else if authViewModel.isLoading {
        ProgressView("Loading...")
      } else if authViewModel.currentSeller == nil {
        FarmCreationView(viewModel: container.makeSellerViewModel())
      } else {
        AdaptiveContentView(container: container)
      }
    }
  }
}
