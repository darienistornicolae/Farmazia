import SwiftUI
import FirebaseAuth

struct ProfileView: View {
  @StateObject private var viewModel: AuthenticationViewModel
  @State private var showingChangePassword = false
  @State private var showingDeleteConfirmation = false

  init(viewModel: @autoclosure @escaping () -> AuthenticationViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("User Information")) {
          if let user = viewModel.currentUser {
            Text("Email: \(user.email ?? "N/A")")
            Text("User ID: \(user.uid)")
          } else {
            Text("No user information available")
          }
        }

        Section {
          Button("Change Password") {
            showingChangePassword = true
          }
        }

        Section {
          Button("Sign Out") {
            viewModel.signOut()
          }
        }

        Section {
          Button("Delete Account") {
            Task {
              await viewModel.deleteAccount()
            }
          }
          .foregroundColor(.red)
        }
      }
      .navigationTitle("Profile")
      .sheet(isPresented: $showingChangePassword) {
        ChangePasswordView(viewModel: viewModel)
      }
      .alert(isPresented: $showingDeleteConfirmation) {
        Alert(
          title: Text("Delete Account"),
          message: Text("Are you sure you want to delete your account? This action cannot be undone."),
          primaryButton: .destructive(Text("Delete")) {
            Task {
              await viewModel.deleteAccount()
            }
          },
          secondaryButton: .cancel()
        )
      }
      .alert(isPresented: Binding<Bool>(
        get: { viewModel.errorMessage != nil },
        set: { _ in viewModel.errorMessage = nil }
      )) {
        Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
      }
    }
  }
}

struct ChangePasswordView: View {
  @StateObject var viewModel: AuthenticationViewModel
  @State private var newPassword = ""
  @State private var confirmPassword = ""
  @Environment(\.presentationMode) var presentationMode

  init(viewModel: @autoclosure @escaping () -> AuthenticationViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Change Password")) {
          SecureField("New Password", text: $newPassword)
          SecureField("Confirm New Password", text: $confirmPassword)
        }

        Section {
          Button("Update Password") {
            if newPassword == confirmPassword {
              Task {
                do {
                  try await Auth.auth().currentUser?.updatePassword(to: newPassword)
                  presentationMode.wrappedValue.dismiss()
                } catch {
                  viewModel.errorMessage = error.localizedDescription
                }
              }
            } else {
              viewModel.errorMessage = "Passwords do not match"
            }
          }
        }
      }
      .navigationTitle("Change Password")
      .alert(isPresented: Binding<Bool>(
        get: { viewModel.errorMessage != nil },
        set: { _ in viewModel.errorMessage = nil }
      )) {
        Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
      }
    }
  }
}
