import SwiftUI
import UIKit

struct AdaptiveContentView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

  var body: some View {
    if horizontalSizeClass == .compact {
      TabBarController()
    } else {
      SidebarView(columnVisibility: $columnVisibility)
    }
  }
}

enum SidebarItem: String, CaseIterable, Identifiable {
  case search = "Search"
  case shoppingCart = "Cart"
  case profile = "Profile"

  var id: String { self.rawValue }

  var label: some View {
    switch self {
    case .search:
      return Label("Search", systemImage: "doc.text.magnifyingglass")
    case .shoppingCart:
      return Label("Cart", systemImage: "cart")
    case .profile:
      return Label("Profile", systemImage: "person.fill")
    }
  }

  @MainActor @ViewBuilder
  var destination: some View {
    switch self {
    case .search:
      CategoryListView()
    case .shoppingCart:
      ShoppingCartView()
    case .profile:
      ProfileView()
    }
  }
}

struct SidebarView: View {
  @State private var selection: SidebarItem? = .search
  @Binding var columnVisibility: NavigationSplitViewVisibility
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      List(SidebarItem.allCases, selection: $selection) { item in
        NavigationLink(value: item) {
          item.label
        }
      }
      .navigationTitle("Menu")
    } detail: {
      if let selectedItem = selection {
        selectedItem.destination
      } else {
        Text("Select an item from the sidebar")
      }
    }
    .onChange(of: selection) { _ in
      if horizontalSizeClass == .regular {
        columnVisibility = .detailOnly
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          columnVisibility = .all
        }) {
          Image(systemName: "sidebar.left")
        }
      }
    }
  }
}

#Preview {
  SidebarView(columnVisibility: .constant(.automatic))
}
