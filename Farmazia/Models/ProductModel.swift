import Foundation

struct AddressModel: Codable {
  var city: String
  var county: String
  var address: String
  var postalCode: String
}

struct ProductModel: Codable {
  var id: String
  var name: String
  var image: String?
  var description: String
  var seller: SellerModel
  var productType: ProductCategory
  var price: Double
  var quantity: Int
  var unit: UnitType
  var isOrganic: Bool
  var isOutOfStock: Bool
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
  var id: String
  var buyer: UserModel
  var seller: SellerModel
  var items: [OrderItemModel]
  var subtotal: Double
  var taxRate: Double?
  var taxAmount: Double?
  var totalPrice: Double
  var status: OrderStatus
  var createdAt: Date
  var updatedAt: Date

  init(
    id: String,
    buyer: UserModel,
    seller: SellerModel,
    items: [OrderItemModel],
    taxRate: Double,
    status: OrderStatus,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.buyer = buyer
    self.seller = seller
    self.items = items
    self.taxRate = taxRate
    self.status = status
    self.createdAt = createdAt
    self.updatedAt = updatedAt

    self.subtotal = items.reduce(0) { $0 + $1.subtotal }
    self.taxAmount = self.subtotal * taxRate
    self.totalPrice = self.subtotal + (self.taxAmount ?? 0)
  }
}

struct OrderItemModel: Codable {
  var product: ProductModel
  var quantity: Int
  var unitPrice: Double
  var subtotal: Double
  var taxRate: Double
  var taxAmount: Double
  var total: Double

  init(product: ProductModel, quantity: Int, taxRate: Double) {
    self.product = product
    self.quantity = quantity
    self.unitPrice = product.price
    self.taxRate = taxRate

    self.subtotal = self.unitPrice * Double(self.quantity)
    self.taxAmount = self.subtotal * self.taxRate
    self.total = self.subtotal + self.taxAmount
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

  static let products: [ProductModel] = [
          ProductModel(
              id: "1",
              name: "Organic Apples",
              image: "https://example.com/apple.jpg",
              description: "Fresh, crisp organic apples from local orchards.",
              seller: seller,
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
              seller: seller,
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
              seller: seller,
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
              seller: seller,
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
              seller: seller,
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
              seller: seller,
              productType: .herbs,
              price: 1.50,
              quantity: 1,
              unit: .bunch,
              isOrganic: true,
              isOutOfStock: true
          )
      ]

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

    static let order: OrderModel = OrderModel(
        id: "O1",
        buyer: buyer,
        seller: seller,
        items: [
            OrderItemModel(product: products[0], quantity: 2, taxRate: 0.08),
            OrderItemModel(product: products[2], quantity: 1, taxRate: 0.08)
        ],
        taxRate: 0.08,
        status: .confirmed,
        createdAt: Date(),
        updatedAt: Date()
    )
}
