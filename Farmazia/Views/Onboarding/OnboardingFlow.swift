import SwiftUI

struct OnboardingFlow: View {
  @ObservedObject var appState: AppState

  var body: some View {
    TabView {
      OnboardingPage(title: "Welcome to FarmApp", description: "Manage your farm with ease", imageName: "leaf.fill")
      OnboardingPage(title: "Track Products", description: "Keep tabs on all your farm products", imageName: "list.bullet")
      OnboardingPage(title: "Manage Categories", description: "Organize products into categories", imageName: "square.grid.2x2")
      FinalOnboardingPage(appState: appState)
    }
    .tabViewStyle(PageTabViewStyle())
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
  }
}

struct OnboardingPage: View {
  let title: String
  let description: String
  let imageName: String
  
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.green)
      Text(title)
        .font(.title)
        .fontWeight(.bold)
      Text(description)
        .font(.body)
        .multilineTextAlignment(.center)
        .padding()
    }
  }
}

struct FinalOnboardingPage: View {
  @ObservedObject var appState: AppState

  var body: some View {
    VStack(spacing: 20) {
      Text("You're all set!")
        .font(.title)
        .fontWeight(.bold)
      Text("Start managing your farm today")
        .font(.body)
      Button("Get Started") {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        appState.hasCompletedOnboarding = true
      }
      .padding()
      .background(Color.green)
      .foregroundColor(.white)
      .cornerRadius(10)
    }
  }
}
