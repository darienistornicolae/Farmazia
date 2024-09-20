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
  case vatServices = "VAT Services"
  case invoices = "Invoices"
  case customers = "Customers"
  case profile = "Profile"

  var id: String { self.rawValue }

  var label: some View {
    switch self {
    case .vatServices:
      return Label("VAT Services", systemImage: "plus.forwardslash.minus")
    case .invoices:
      return Label("Invoices", systemImage: "list.bullet.clipboard")
    case .customers:
      return Label("Customers", systemImage: "person.2.fill")
    case .profile:
      return Label("Profile", systemImage: "person.fill")
    }
  }

  @MainActor @ViewBuilder
  var destination: some View {
    switch self {
    case .vatServices:
      SettingsView()
    case .invoices:
      ProductListView(products: MockData.products)
    case .customers:
      ShoppingCartView()
    case .profile:
      ProfileView()
    }
  }
}

struct SidebarView: View {
  @State private var selection: SidebarItem? = .vatServices
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
