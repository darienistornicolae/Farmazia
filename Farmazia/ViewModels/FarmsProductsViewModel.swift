import Foundation
import Combine

class FarmProductsViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    @Published var productToEdit: ProductModel?
    @Published var activeBottomSheet: BottomSheetItem?
    @Published var searchText: String = ""
    @Published var selectedCategory: ProductCategory?

    private let sellerService: SellerServiceProtocol
    private let productService: ProductServiceProtocol

    init(sellerService: SellerServiceProtocol, productService: ProductServiceProtocol) {
        self.sellerService = sellerService
        self.productService = productService
    }

    var filteredProducts: [ProductModel] {
        products.filter { product in
            (searchText.isEmpty || product.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == nil || product.productType == selectedCategory)
        }
    }

    func loadProducts() async {
        do {
            products = try await productService.fetchAllProducts()
        } catch {
            print("Error loading products: \(error)")
        }
    }

    func addProduct() {
        productToEdit = nil
        activeBottomSheet = .addProduct
    }

    func editProduct(_ product: ProductModel) {
        productToEdit = product
        activeBottomSheet = .addProduct
    }

    func moveProduct(from source: IndexSet, to destination: Int) {
        products.move(fromOffsets: source, toOffset: destination)
        // You might want to update this order in your backend as well
    }

    func deleteProduct(at offsets: IndexSet) async {
        for index in offsets {
            if let productId = products[index].id {
                do {
                    try await productService.deleteProduct(withId: productId)
                    products.remove(at: index)
                } catch {
                    print("Error deleting product: \(error)")
                }
            }
        }
    }

    func updateProduct(_ updatedProduct: ProductModel) async {
        do {
            try await productService.updateProduct(updatedProduct)
            if let index = products.firstIndex(where: { $0.id == updatedProduct.id }) {
                products[index] = updatedProduct
            }
        } catch {
            print("Error updating product: \(error)")
        }
    }
}

enum BottomSheetItem: Identifiable {
    case addProduct

    var id: Self { self }
}
