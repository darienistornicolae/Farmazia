import Combine
import Foundation
import FirebaseAuth

class AuthenticationManager: AuthenticationManagerProtocol {
  private let auth = Auth.auth()
  private var handle: AuthStateDidChangeListenerHandle?
  private let userSubject = CurrentValueSubject<User?, Never>(nil)

  var currentUser: User? {
    return auth.currentUser
  }

  var userPublisher: AnyPublisher<User?, Never> {
    return userSubject.eraseToAnyPublisher()
  }

  init() {
    setupAuthStateListener()
  }

  private func setupAuthStateListener() {
    handle = auth.addStateDidChangeListener { [weak self] _, user in
      self?.userSubject.send(user)
    }
  }

  deinit {
    if let handle = handle {
      auth.removeStateDidChangeListener(handle)
    }
  }

  func signUp(email: String, password: String) async throws {
    try await auth.createUser(withEmail: email, password: password)
  }

  func signIn(email: String, password: String) async throws {
    try await auth.signIn(withEmail: email, password: password)
  }

  func signOut() throws {
    try auth.signOut()
  }

  func resetPassword(email: String) async throws {
    try await auth.sendPasswordReset(withEmail: email)
  }

  func updatePassword(newPassword: String) async throws {
    guard let user = auth.currentUser else {
      throw NSError(domain: "AuthenticationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])
    }
    try await user.updatePassword(to: newPassword)
  }

  func deleteAccount() async throws {
    guard let user = auth.currentUser else {
      throw NSError(domain: "AuthenticationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])
    }
    try await user.delete()
  }
}
