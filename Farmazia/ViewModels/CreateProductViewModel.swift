import Foundation
import UIKit

@MainActor
class CreateProductViewModel: ObservableObject {
  @Published var name: String = ""
  @Published var description: String = ""
  @Published var price: String = ""
  @Published var quantity: String = ""
  @Published var selectedCategory: ProductCategory = .vegetables
  @Published var selectedUnit: UnitType = .kg
  @Published var isOrganic: Bool = false
  @Published var isOutOfStock: Bool = false
  @Published var selectedImage: UIImage?
  @Published var errorMessage: String?

  private let sellerViewModel: SellerViewModel
  private let storageManager: FirebaseStorageManagerProtocol
  let existingProduct: ProductModel?

  init(sellerViewModel: SellerViewModel, storageManager: FirebaseStorageManagerProtocol, existingProduct: ProductModel? = nil) {
    self.sellerViewModel = sellerViewModel
    self.storageManager = storageManager
    self.existingProduct = existingProduct

    if let product = existingProduct {
      self.name = product.name
      self.description = product.description
      self.price = String(format: "%.2f", product.price)
      self.quantity = String(product.quantity)
      self.selectedCategory = product.productType
      self.selectedUnit = product.unit
      self.isOrganic = product.isOrganic
      self.isOutOfStock = product.isOutOfStock
    }
  }

  var isEditMode: Bool {
    existingProduct != nil
  }

  func saveProduct() async -> Bool {
    guard let priceValue = Double(price),
          let quantityValue = Int(quantity) else {
      errorMessage = "Invalid price or quantity"
      return false
    }

    var imageUrl: String?
    if let image = selectedImage {
      do {
        let imagePath = "product_images/\(UUID().uuidString).jpg"
        imageUrl = try await storageManager.uploadImage(image, path: imagePath)
      } catch {
        errorMessage = "Failed to upload image: \(error.localizedDescription)"
        return false
      }
    }

    let product = ProductModel(
      id: existingProduct?.id,
      name: name,
      image: imageUrl ?? existingProduct?.image,
      description: description,
      sellerId: sellerViewModel.seller?.id ?? "",
      productType: selectedCategory,
      price: priceValue,
      quantity: quantityValue,
      unit: selectedUnit,
      isOrganic: isOrganic,
      isOutOfStock: isOutOfStock
    )

    do {
      if isEditMode {
        await sellerViewModel.updateProduct(product)
      } else {
        await sellerViewModel.addProduct(product)
      }
      return true
    }
  }
}
