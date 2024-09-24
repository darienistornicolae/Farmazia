import SwiftUI

enum ActiveSheet: Identifiable, Hashable {
  case changePassword, editFarm
  var id: Self { self }
}

struct ProfileView: View {
  @StateObject private var authViewModel: AuthenticationViewModel
  @StateObject private var dataManager: DataManager
  @State private var activeSheet: ActiveSheet?
  @State private var showingDeleteConfirmation = false
  @State private var showingFarmProducts = false

  private let container: DependencyContainer

  init(container: DependencyContainer) {
    self.container = container
    self._authViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
    self._dataManager = StateObject(wrappedValue: container.makeDataManager())
  }

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("User Information")) {
          if let user = authViewModel.currentUser {
            Text("Email: \(user.email ?? "N/A")")
          } else {
            Text("No user information available")
          }
        }

        Section(header: Text("Farm Details")) {
          if let seller = dataManager.currentSeller {
            Text("Farm Name: \(seller.farmName)")
            Text("Description: \(seller.farmDescription)")
            Button("Edit Farm Details") {
              activeSheet = .editFarm
            }
          } else {
            Text("Farm details not available")
          }
        }

        Section(header: Text("Products")) {
          Button("Manage Products") {
            showingFarmProducts = true
          }
        }

        Section("Account Management") {
          Button("Change Password") {
            activeSheet = .changePassword
          }
          Button("Sign Out") {
            authViewModel.signOut()
          }
          .foregroundStyle(.red)
          Button("Delete Account") {
            showingDeleteConfirmation = true
          }
          .foregroundStyle(.red)
        }
      }
      .navigationTitle("Profile")
      .sheet(item: $activeSheet) { item in
        switch item {
        case .changePassword:
          ChangePasswordView(viewModel: authViewModel)
        case .editFarm:
          FarmDetailsView(dataManager: dataManager)
        }
      }
      .fullScreenCover(isPresented: $showingFarmProducts) {
        FarmProductsView(dataManager: dataManager)
      }
      .alert(isPresented: $showingDeleteConfirmation) {
        Alert(
          title: Text("Delete Account"),
          message: Text("Are you sure you want to delete your account? This action cannot be undone."),
          primaryButton: .destructive(Text("Delete")) {
            Task {
              await authViewModel.deleteAccount()
            }
          },
          secondaryButton: .cancel()
        )
      }
    }
  }
}
