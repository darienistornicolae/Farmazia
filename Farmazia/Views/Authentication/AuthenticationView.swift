import SwiftUI

struct AuthenticationView: View {
  @StateObject private var viewModel: AuthenticationViewModel
  @State private var email = ""
  @State private var password = ""
  @State private var isSignUp = false

  init(viewModel: @autoclosure @escaping () -> AuthenticationViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(isSignUp ? "Sign Up" : "Sign In")) {
          TextField("Email", text: $email)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
          SecureField("Password", text: $password)
        }

        Section {
          Button(isSignUp ? "Sign Up" : "Sign In") {
            Task {
              if isSignUp {
                await viewModel.signUp(email: email, password: password)
              } else {
                await viewModel.signIn(email: email, password: password)
              }
            }
          }
        }

        Section {
          Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
            isSignUp.toggle()
          }
        }

        if !isSignUp {
          Section {
            NavigationLink("Forgot Password?") {
              ResetPasswordView(viewModel: viewModel)
            }
          }
        }
      }
      .navigationTitle(isSignUp ? "Create Account" : "Welcome Back")
      .alert(isPresented: Binding<Bool>(
        get: { viewModel.errorMessage != nil },
        set: { _ in viewModel.errorMessage = nil }
      )) {
        Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
      }
    }
  }
}
