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
          .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
      } else if !authViewModel.isAuthenticated {
        AuthenticationView(viewModel: authViewModel)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
      } else if sellerViewModel.seller == nil {
        FarmCreationView(viewModel: sellerViewModel)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
      } else {
        AdaptiveContentView(container: container)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
      }
    }
  }
}
