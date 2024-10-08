import SwiftUI
import Combine

struct FarmProductsView: View {
  @ObservedObject var dataManager: DataManager
  @Environment(\.dismiss) var dismiss
  @State private var productToEditOrAdd: ProductModel?
  @State private var searchText = ""
  @State private var selectedCategory: ProductCategory?
  @State private var refreshTrigger = false
  
  private var filteredProducts: [ProductModel] {
    dataManager.products.filter { product in
      (searchText.isEmpty || product.name.localizedCaseInsensitiveContains(searchText)) &&
      (selectedCategory == nil || product.productType == selectedCategory)
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        categoryFilterView
        
        ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(filteredProducts) { product in
              FarmProductCardView(product: product)
                .onTapGesture {
                  createOrEditProduct(product)
                }
                .contextMenu {
                  Button(action: { createOrEditProduct(product) }) {
                    Label("Edit", systemImage: "pencil")
                  }
                  Button(role: .destructive) {
                    deleteProduct(product)
                  } label: {
                    Label("Delete", systemImage: "trash")
                  }
                }
            }
          }
          .padding()
        }
      }
      .navigationTitle("My Products")
      .searchable(text: $searchText, prompt: "Search products")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Done") { dismiss() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            createOrEditProduct(nil)
          }) {
            Image(systemName: "plus")
          }
        }
      }
      .fullScreenCover(item: $productToEditOrAdd) { product in
        CreateProductView(existingProduct: product)
          .environmentObject(dataManager)
      }

      .onReceive(dataManager.productUpdatePublisher) { _ in
        Task {
          refreshTrigger.toggle()
          await dataManager.loadSellerProducts()
        }
      }
      .id(refreshTrigger)
    }
    .task {
      await dataManager.loadSellerProducts()
    }
  }  
}

struct CategoryButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(20)
    }
  }
}

// MARK: Private
private extension FarmProductsView {
  var categoryFilterView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        CategoryButton(title: "All", isSelected: selectedCategory == nil) {
          selectedCategory = nil
        }
        ForEach(ProductCategory.allCases, id: \.self) { category in
          CategoryButton(title: category.description, isSelected: selectedCategory == category) {
            selectedCategory = category
          }
        }
      }
      .padding(.horizontal)
    }
    .padding(.vertical, 8)
    .background(Color.gray.opacity(0.1))
  }

  func createOrEditProduct(_ product: ProductModel?) {
    if let product = product {
      productToEditOrAdd = product
    } else {
      productToEditOrAdd = dataManager.createDefaultProduct()
    }
  }

  func deleteProduct(_ product: ProductModel) {
    Task {
      if let productId = product.id {
        try? await dataManager.deleteProduct(withId: productId)
        await dataManager.loadSellerProducts()
      }
    }
  }
}
