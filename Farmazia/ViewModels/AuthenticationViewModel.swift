import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var isAuthenticated = false
  @Published var errorMessage: String?
  @Published var currentUser: User?

  private let authManager: AuthenticationManagerProtocol
  private let sellerService: SellerServiceProtocol
  private let productService: ProductServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  init(
    authManager: AuthenticationManagerProtocol,
    sellerService: SellerServiceProtocol,
    productService: ProductServiceProtocol
  ) {
    self.authManager = authManager
    self.sellerService = sellerService
    self.productService = productService
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
      guard let userId = authManager.currentUser?.uid else {
        throw NSError(domain: "AuthenticationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])
      }
      let seller = try await sellerService.getSeller(id: userId)

      guard let sellerId = seller?.id else {
        throw NSError(domain: "AuthenticationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No seller id discovered"])
      }

      try await productService.deleteAllProducts(for: sellerId)
      try await sellerService.deleteSeller(id: sellerId)

      try await authManager.deleteAccount()
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }
}
