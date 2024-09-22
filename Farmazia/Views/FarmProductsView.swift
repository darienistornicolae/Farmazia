import SwiftUI

struct FarmProductsView: View {
  @ObservedObject var viewModel: SellerViewModel
  @State private var showingProductForm = false
  @State private var productToEdit: ProductModel?
  @State private var searchText = ""
  @State private var selectedCategory: ProductCategory?
  @Environment(\.dismiss) var dismiss

  private var filteredProducts: [ProductModel] {
    viewModel.products.filter { product in
      (searchText.isEmpty || product.name.localizedCaseInsensitiveContains(searchText)) &&
      (selectedCategory == nil || product.productType == selectedCategory)
    }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        categoryFilterView

        ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(filteredProducts) { product in
              FarmProductCardView(product: product)
                .onTapGesture {
                  editProduct(product)
                }
                .contextMenu {
                  Button(action: { editProduct(product) }) {
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
            addNewProduct()
          }) {
            Image(systemName: "plus")
          }
        }
      }
      .fullScreenCover(isPresented: $showingProductForm) {
        CreateProductView(
          sellerViewModel: viewModel,
          storageManager: DependencyContainer().storageManager,
          existingProduct: productToEdit,
          shouldDismiss: $showingProductForm
        )
      }
      .onChange(of: showingProductForm) { isPresented in
        if !isPresented {
          productToEdit = nil
          Task {
            await viewModel.loadSellerProducts()
          }
        }
      }
    }
    .task {
      await viewModel.loadSellerProducts()
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

  func deleteProduct(_ product: ProductModel) {
    Task {
      if let productId = product.id {
        await viewModel.deleteProduct(withId: productId)
      }
    }
  }

  func editProduct(_ product: ProductModel) {
    productToEdit = product
    showingProductForm = true
  }

  func addNewProduct() {
    productToEdit = nil
    showingProductForm = true
  }
}
