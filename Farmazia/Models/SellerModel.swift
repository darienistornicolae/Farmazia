import Foundation

struct UserModel: Codable {
    var id: String
    var fullName: String
    var contactInformation: ContactModel
}

typealias BuyerModel = UserModel

struct SellerModel: Codable {
    var id: String
    var fullName: String
    var contactInformation: ContactModel
    var products: [ProductModel]
    var rating: Double
}

struct ContactModel: Codable {
    var email: String
    var phoneNumber: String
    var addressInformation: AddressModel
}
