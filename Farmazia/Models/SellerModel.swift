import Foundation
import FirebaseFirestore

struct UserModel: Codable {
  @DocumentID var id: String?
  var fullName: String
  var contactInformation: ContactModel
  
  init(id: String? = nil, fullName: String, contactInformation: ContactModel) {
    self.id = id
    self.fullName = fullName
    self.contactInformation = contactInformation
  }
}

typealias BuyerModel = UserModel

struct SellerModel: Codable, Identifiable {
  @DocumentID var id: String?
  var fullName: String
  var contactInformation: ContactModel
  var farmName: String
  var farmDescription: String
  var productIds: [String]
  var rating: Double

  init(
    id: String? = nil,
    fullName: String,
    contactInformation: ContactModel,
    farmName: String,
    farmDescription: String,
    productIds: [String],
    rating: Double
  ) {
    self.id = id
    self.fullName = fullName
    self.contactInformation = contactInformation
    self.farmName = farmName
    self.farmDescription = farmDescription
    self.productIds = productIds
    self.rating = rating
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case fullName
    case contactInformation
    case farmName
    case farmDescription
    case productIds
    case rating
  }
}

struct ContactModel: Codable {
  var email: String
  var phoneNumber: String
  var addressInformation: AddressModel
}

struct AddressModel: Codable {
  var city: String
  var county: String
  var address: String
  var postalCode: String
}
