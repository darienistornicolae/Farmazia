import SwiftUI

struct TabBarController: View {

  init() {
    tabBarDivider()
  }

  var body: some View {
    TabView {
      CategoryListView()
        .tabItem {
          Label("Search", systemImage: "doc.text.magnifyingglass")
        }

      ShoppingCartView()
        .tabItem {
          Label("Cart", systemImage: "cart")
        }

      ProfileView()
        .tabItem {
          Label("Profile", systemImage: "person.fill")
        }
    }
    .tint(.green)
  }
}

private extension TabBarController {
  func tabBarDivider() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
  }
}

