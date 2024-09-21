import SwiftUI

struct ResetPasswordView: View {
  @StateObject var viewModel: AuthenticationViewModel
  @State private var email = ""
  @Environment(\.presentationMode) var presentationMode
  
  init(viewModel: @autoclosure @escaping () -> AuthenticationViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Reset Password")) {
          TextField("Email", text: $email)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
        }

        Section {
          Button("Send Reset Link") {
            Task {
              await viewModel.resetPassword(email: email)
            }
          }
        }
      }
      .navigationTitle("Reset Password")
      .alert(isPresented: Binding<Bool>(
        get: { viewModel.errorMessage != nil },
        set: { _ in viewModel.errorMessage = nil }
      )) {
        Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
      }
      .onChange(of: viewModel.errorMessage) { errorMessage in
        if errorMessage == nil {
          presentationMode.wrappedValue.dismiss()
        }
      }
    }
  }
}
