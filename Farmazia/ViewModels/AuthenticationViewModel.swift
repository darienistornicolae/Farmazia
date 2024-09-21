import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var isAuthenticated = false
  @Published var errorMessage: String?
  @Published var currentUser: User?

  private let authManager: AuthenticationManagerProtocol
  private var cancellables = Set<AnyCancellable>()

  init(authManager: AuthenticationManagerProtocol) {
    self.authManager = authManager
    setupUserSubscription()
  }

  private func setupUserSubscription() {
    authManager.userPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] user in
        self?.currentUser = user
        self?.isAuthenticated = user != nil
      }
      .store(in: &cancellables)
  }

  func signUp(email: String, password: String) async {
    do {
      try await authManager.signUp(email: email, password: password)
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  func signIn(email: String, password: String) async {
    do {
      try await authManager.signIn(email: email, password: password)
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  func signOut() {
    do {
      try authManager.signOut()
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  func resetPassword(email: String) async {
    do {
      try await authManager.resetPassword(email: email)
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  func deleteAccount() async {
    do {
      try await authManager.deleteAccount()
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }
}
