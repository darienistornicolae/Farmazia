import SwiftUI

fileprivate enum Field: Hashable {
  case fullName, email, phoneNumber, farmName, farmDescription, city, county, address, postalCode
  static var allCases: [Field] {
    return [.fullName, .email, .phoneNumber, .farmName, .farmDescription, .city, .county, .address, .postalCode]
  }
}

struct CreateFarmView: View {
  @ObservedObject var dataManager: DataManager
  @Environment(\.dismiss) var dismiss
  @FocusState private var focusedField: Field?

  @State private var fullName: String = ""
  @State private var email: String = ""
  @State private var phoneNumber: String = ""
  @State private var farmName: String = ""
  @State private var farmDescription: String = ""
  @State private var city: String = ""
  @State private var county: String = ""
  @State private var address: String = ""
  @State private var postalCode: String = ""

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Seller Information")) {
          TextField("Full Name", text: $fullName)
            .focused($focusedField, equals: .fullName)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }
          TextField("Email", text: $email)
            .focused($focusedField, equals: .email)
            .keyboardType(.emailAddress)
            .submitLabel(.next)
            .onSubmit { focusedField = .phoneNumber }
          TextField("Phone Number", text: $phoneNumber)
            .focused($focusedField, equals: .phoneNumber)
            .keyboardType(.phonePad)
            .submitLabel(.next)
            .onSubmit { focusedField = .farmName }
        }

        Section(header: Text("Farm Information")) {
          TextField("Farm Name", text: $farmName)
            .focused($focusedField, equals: .farmName)
            .submitLabel(.next)
            .onSubmit { focusedField = .farmDescription }
          TextEditor(text: $farmDescription)
            .focused($focusedField, equals: .farmDescription)
            .frame(height: 100)
            .onSubmit { focusedField = .city }
        }

        Section(header: Text("Address")) {
          TextField("City", text: $city)
            .focused($focusedField, equals: .city)
            .submitLabel(.next)
            .onSubmit { focusedField = .county }
          TextField("County", text: $county)
            .focused($focusedField, equals: .county)
            .submitLabel(.next)
            .onSubmit { focusedField = .address }
          TextField("Address", text: $address)
            .focused($focusedField, equals: .address)
            .submitLabel(.next)
            .onSubmit { focusedField = .postalCode }
          TextField("Postal Code", text: $postalCode)
            .focused($focusedField, equals: .postalCode)
            .submitLabel(.done)
        }

        Section {
          Button("Save Farm") {
            Task {
              await saveFarm()
            }
          }
        }
      }
      .keyboardToolbar(focusedField: $focusedField, fields: Field.allCases)
      .navigationTitle("Create Your Farm")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          focusedField = .fullName
        }
      }
    }
  }

  private func saveFarm() async {
    let addressInfo = AddressModel(
      city: city,
      county: county,
      address: address,
      postalCode: postalCode
    )

    dataManager.createOrUpdateFarm(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      farmName: farmName,
      farmDescription: farmDescription,
      addressInfo: addressInfo
    )
    dismiss()
  }
}
