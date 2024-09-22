import SwiftUI
import FirebaseAuth

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
    }
  }
}
