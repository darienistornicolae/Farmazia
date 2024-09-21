import SwiftUI

struct TabBarController: View {
  let container: DependencyContainer
  
  init(container: DependencyContainer) {
    self.container = container
    tabBarDivider()
  }

  var body: some View {
    TabView {
      CategoryListView(viewModel: container.makeCategoryListViewModel())
        .tabItem {
          Label("Search", systemImage: "doc.text.magnifyingglass")
        }

      ShoppingCartView()
        .tabItem {
          Label("Cart", systemImage: "cart")
        }

      ProfileView(viewModel: container.makeAuthenticationViewModel())
        .tabItem {
          Label("Profile", systemImage: "person.fill")
        }
    }
    .tint(.green)
  }

  private func tabBarDivider() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
  }
}
