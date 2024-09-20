import SwiftUI

struct TabBarController: View {

  init() {
    tabBarDivider()
  }

  var body: some View {
    TabView {
      SettingsView()
        .tabItem {
          Label("VAT Services", systemImage: "plus.forwardslash.minus")
        }

      ProductListView(products: MockData.products)
        .tabItem {
          Label("Invoices", systemImage: "list.bullet.clipboard")
        }

      ShoppingCartView()
        .tabItem {
          Label("Customers", systemImage: "person.2.fill")
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

