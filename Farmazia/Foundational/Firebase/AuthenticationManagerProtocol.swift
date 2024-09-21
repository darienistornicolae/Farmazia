import Foundation
import FirebaseAuth
import Combine

protocol AuthenticationManagerProtocol {
  var currentUser: User? { get }
  var userPublisher: AnyPublisher<User?, Never> { get }
  func signUp(email: String, password: String) async throws
  func signIn(email: String, password: String) async throws
  func signOut() throws
  func resetPassword(email: String) async throws
  func updatePassword(newPassword: String) async throws
  func deleteAccount() async throws
}
