import Foundation
import FirebaseFirestore

struct AddressModel: Codable {
  var city: String
  var county: String
  var address: String
  var postalCode: String
}

struct ProductModel: Codable, Hashable {
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

enum UnitType: String, Codable {
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

struct MockData {

  static let seller: SellerModel = SellerModel(
    id: "S1",
    fullName: "Green Valley Farm",
    contactInformation: ContactModel(
      email: "info@greenvalleyfarm.com",
      phoneNumber: "+1234567890",
      addressInformation: AddressModel(
        city: "Farmville",
        county: "Green County",
        address: "123 Farm Road",
        postalCode: "12345"
      )
    ),
    products: [],
    rating: 4.8
  )

  static let buyer: UserModel = UserModel(
    id: "U1",
    fullName: "John Doe",
    contactInformation: ContactModel(
      email: "john.doe@example.com",
      phoneNumber: "+9876543210",
      addressInformation: AddressModel(
        city: "Springfield",
        county: "Springfield County",
        address: "456 Main St",
        postalCode: "67890"
      )
    )
  )

  static let products: [ProductModel] = [
    ProductModel(
      id: "1",
      name: "Organic Apples",
      image: "https://example.com/apple.jpg",
      description: "Fresh, crisp organic apples from local orchards.",
      sellerId: seller.id!,
      productType: .fruits,
      price: 2.99,
      quantity: 14,
      unit: .kg,
      isOrganic: true,
      isOutOfStock: false
    ),
    ProductModel(
      id: "2",
      name: "Organic Carrots",
      image: "https://example.com/carrot.jpg",
      description: "Sweet and crunchy organic carrots, perfect for snacking or cooking.",
      sellerId: seller.id!,
      productType: .vegetables,
      price: 1.99,
      quantity: 500,
      unit: .gram,
      isOrganic: true,
      isOutOfStock: false
    ),
    ProductModel(
      id: "3",
      name: "Whole Grain Bread",
      image: "https://example.com/bread.jpg",
      description: "Freshly baked whole grain bread, rich in fiber and nutrients.",
      sellerId: seller.id!,
      productType: .grains,
      price: 3.50,
      quantity: 1,
      unit: .piece,
      isOrganic: false,
      isOutOfStock: false
    ),
    ProductModel(
      id: "4",
      name: "Organic Milk",
      image: "https://example.com/milk.jpg",
      description: "Creamy organic milk from grass-fed cows.",
      sellerId: seller.id!,
      productType: .dairy,
      price: 4.99,
      quantity: 1,
      unit: .liter,
      isOrganic: true,
      isOutOfStock: false
    ),
    ProductModel(
      id: "5",
      name: "Free-Range Chicken",
      image: "https://example.com/chicken.jpg",
      description: "Tender, free-range chicken raised without antibiotics.",
      sellerId: seller.id!,
      productType: .meat,
      price: 8.99,
      quantity: 1,
      unit: .kg,
      isOrganic: false,
      isOutOfStock: false
    ),
    ProductModel(
      id: "6",
      name: "Fresh Basil",
      image: "https://example.com/basil.jpg",
      description: "Aromatic fresh basil, perfect for pasta dishes and salads.",
      sellerId: seller.id!,
      productType: .herbs,
      price: 1.50,
      quantity: 1,
      unit: .bunch,
      isOrganic: true,
      isOutOfStock: true
    )
  ]

  static let order: OrderModel = OrderModel(
    id: "O1",
    buyerId: buyer.id!,
    sellerId: seller.id!,
    items: [
      OrderItemModel(productId: products[0].id!, quantity: 2, unitPrice: products[0].price, taxRate: 0.08),
      OrderItemModel(productId: products[2].id!, quantity: 1, unitPrice: products[2].price, taxRate: 0.08)
    ],
    taxRate: 0.08,
    status: .confirmed,
    createdAt: Date(),
    updatedAt: Date()
  )
}
