import SwiftUI

struct ContentView: View {
  @ObservedObject var appState: AppState
  @StateObject private var authViewModel: AuthenticationViewModel
  @StateObject private var dataManager: DataManager
  let container: DependencyContainer

  init(container: DependencyContainer) {
    self.container = container
    self.appState = container.appState
    self._authViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
    self._dataManager = StateObject(wrappedValue: container.makeDataManager())
  }

  var body: some View {
    ZStack {
      if !appState.hasCompletedOnboarding {
        OnboardingFlow(appState: appState)
          .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
      } else if !authViewModel.isAuthenticated {
        AuthenticationView(viewModel: authViewModel)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
      } else if authViewModel.isLoading {
        ProgressView("Loading...")
      } else if dataManager.currentSeller == nil {
        CreateFarmView(dataManager: dataManager)
      } else {
        AdaptiveContentView(container: container)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
      }
    }
    .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
      if isAuthenticated {
        dataManager.loadCurrentSeller()
      }
    }
  }
}
