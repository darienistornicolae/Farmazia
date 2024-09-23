import SwiftUI

struct ContentView: View {
  @ObservedObject var appState: AppState
  @StateObject private var authViewModel: AuthenticationViewModel
  @StateObject private var sellerViewModel: SellerViewModel
  let container: DependencyContainer

  init(container: DependencyContainer) {
    self.container = container
    self.appState = container.appState
    self._authViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
    self._sellerViewModel = StateObject(wrappedValue: container.makeSellerViewModel())
  }

  var body: some View {
    ZStack {
      if !appState.hasCompletedOnboarding {
        OnboardingFlow(appState: appState)
      } else if !authViewModel.isAuthenticated {
        AuthenticationView(viewModel: authViewModel)
      } else if authViewModel.isLoading {
        ProgressView("Loading...")
      } else if sellerViewModel.seller == nil {
        CreateFarmView(viewModel: sellerViewModel)
      } else {
        AdaptiveContentView(container: container)
      }
    }
    .onChange(of: authViewModel.isAuthenticated || sellerViewModel.farmCreated) { isAuthenticated in
      if isAuthenticated {
        Task {
          await sellerViewModel.loadCurrentSeller()
        }
      }
    }
  }
}
