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

struct SellerModel: Codable {
  @DocumentID var id: String?
  var fullName: String
  var contactInformation: ContactModel
  var products: [ProductModel]
  var rating: Double

  init(id: String? = nil, fullName: String, contactInformation: ContactModel, products: [ProductModel], rating: Double) {
    self.id = id
    self.fullName = fullName
    self.contactInformation = contactInformation
    self.products = products
    self.rating = rating
  }
}

struct ContactModel: Codable {
  var email: String
  var phoneNumber: String
  var addressInformation: AddressModel
}
