import Foundation
import FirebaseFirestore

struct ProductModel: Codable, Hashable, Identifiable {
  @DocumentID var id: String?
  var name: String
  var image: String?
  var description: String
  var sellerId: String
  var productType: ProductCategory
  var price: Double
  var quantity: Int
  var unit: UnitType
  var isOrganic: Bool
  var isOutOfStock: Bool

  init(
    id: String? = nil,
    name: String,
    image: String? = nil,
    description: String,
    sellerId: String,
    productType: ProductCategory,
    price: Double,
    quantity: Int,
    unit: UnitType,
    isOrganic: Bool,
    isOutOfStock: Bool
  ) {
    self.id = id
    self.name = name
    self.image = image
    self.description = description
    self.sellerId = sellerId
    self.productType = productType
    self.price = price
    self.quantity = quantity
    self.unit = unit
    self.isOrganic = isOrganic
    self.isOutOfStock = isOutOfStock
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
    lhs.id == rhs.id
  }
}

enum ProductCategory: String, Codable, CaseIterable {
  case fruits
  case vegetables
  case grains
  case dairy
  case meat
  case herbs

  var description: String {
    switch self {
    case .fruits: return "Fruits"
    case .vegetables: return "Vegetables"
    case .grains: return "Grains"
    case .dairy: return "Dairy"
    case .meat: return "Meat"
    case .herbs: return "Herbs"
    }
  }
}

enum UnitType: String, Codable, CaseIterable {
  case kg
  case gram
  case piece
  case bunch
  case liter
}

struct OrderModel: Codable {
  @DocumentID var id: String?
  var buyerId: String
  var sellerId: String
  var items: [OrderItemModel]
  var taxRate: Double
  var status: OrderStatus
  var createdAt: Date
  var updatedAt: Date

  var subtotal: Double {
    items.reduce(0) { $0 + $1.subtotal }
  }

  var taxAmount: Double {
    subtotal * taxRate
  }

  var totalPrice: Double {
    subtotal + taxAmount
  }

  init(id: String? = nil,
       buyerId: String,
       sellerId: String,
       items: [OrderItemModel],
       taxRate: Double,
       status: OrderStatus,
       createdAt: Date,
       updatedAt: Date) {
    self.id = id
    self.buyerId = buyerId
    self.sellerId = sellerId
    self.items = items
    self.taxRate = taxRate
    self.status = status
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

struct OrderItemModel: Codable {
  var productId: String
  var quantity: Int
  var unitPrice: Double
  var taxRate: Double

  var subtotal: Double {
    unitPrice * Double(quantity)
  }

  var taxAmount: Double {
    subtotal * taxRate
  }

  var total: Double {
    subtotal + taxAmount
  }

  init(productId: String, quantity: Int, unitPrice: Double, taxRate: Double) {
    self.productId = productId
    self.quantity = quantity
    self.unitPrice = unitPrice
    self.taxRate = taxRate
  }
}

enum OrderStatus: String, Codable {
  case pending
  case confirmed
  case shipped
  case delivered
  case cancelled
}

enum SortOrder {
  case priceAscending, priceDescending, dateAscending, dateDescending
}

