import Foundation

@MainActor
class SellerViewModel: ObservableObject {
  @Published var seller: SellerModel?
  @Published var errorMessage: String?
  @Published var products: [ProductModel] = []
  @Published var hasProducts: Bool = false
  @Published var farmCreated: Bool = false

  private let sellerService: SellerServiceProtocol
  private let authManager: AuthenticationManagerProtocol
  let productService: ProductServiceProtocol

  init(
    sellerService: SellerServiceProtocol,
    authManager: AuthenticationManagerProtocol,
    productService: ProductServiceProtocol
  ) {
    self.sellerService = sellerService
    self.authManager = authManager
    self.productService = productService

    Task {
      await loadCurrentSeller()
      await loadSellerProducts()
    }
  }

  func loadCurrentSeller() async {
    guard let userId = authManager.currentUser?.uid else {
      errorMessage = "No authenticated user found"
      return
    }
    do {
      seller = try await sellerService.getSeller(id: userId)
    } catch {
      errorMessage = "Failed to load seller: \(error.localizedDescription)"
    }
  }

  func createOrUpdateFarm(
    fullName: String,
    email: String,
    phoneNumber: String,
    farmName: String,
    farmDescription: String,
    addressInfo: AddressModel
  ) async {
    guard let userId = authManager.currentUser?.uid else {
      errorMessage = "No authenticated user found"
      return
    }

    do {
      let newSeller = SellerModel(
        id: userId,
        fullName: fullName,
        contactInformation: ContactModel(
          email: email,
          phoneNumber: phoneNumber,
          addressInformation: addressInfo
        ),
        farmName: farmName,
        farmDescription: farmDescription,
        products: [],
        rating: 0.0
      )
      
      if let existingSeller = seller {
        try await sellerService.updateSeller(newSeller)
      } else {
        try await sellerService.createSeller(newSeller)
      }

      seller = newSeller
      farmCreated = true
    } catch {
      errorMessage = "Failed to create/update farm: \(error.localizedDescription)"
    }
  }

  func loadSellerProducts() async {
    guard let sellerId = seller?.id else {
      errorMessage = "Seller ID not found"
      return
    }
    do {
      products = try await productService.fetchProductsBySeller(sellerId: sellerId)
      hasProducts = !products.isEmpty

      if var updatedSeller = seller {
        updatedSeller.products = products
        seller = updatedSeller
      }
    } catch {
      errorMessage = "Failed to load products: \(error.localizedDescription)"
    }
  }
  
  func addProduct(_ product: ProductModel) async throws {
      let productId = try await productService.addProduct(product)
      var newProduct = product
      newProduct.id = productId
      products.append(newProduct)
  }

  func moveProduct(from source: IndexSet, to destination: Int) {
    products.move(fromOffsets: source, toOffset: destination)
  }

  func updateProduct(_ product: ProductModel) async {
      do {
          try await productService.updateProduct(product)
          if let index = products.firstIndex(where: { $0.id == product.id }) {
              products[index] = product
          }
      } catch {
          errorMessage = "Error updating product: \(error.localizedDescription)"
      }
  }

  
  func deleteProduct(withId id: String) async {
      do {
          try await productService.deleteProduct(withId: id)
          products.removeAll { $0.id == id }
      } catch {
          errorMessage = "Error deleting product: \(error.localizedDescription)"
      }
  }
}
