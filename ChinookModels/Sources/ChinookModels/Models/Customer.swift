import SwiftData

@Model
public nonisolated final class Customer {
  @Attribute(.unique)
  public var chinookId: Int
  public var firstName: String
  public var lastName: String
  public var company: String?
  public var address: String?
  public var city: String?
  public var state: String?
  public var country: String?
  public var postalCode: String?
  public var phone: String?
  public var fax: String?
  public var email: String
  public var supportRepresentative: Employee?

  init(
    chinookId: Int,
    firstName: String,
    lastName: String,
    company: String?,
    address: String?,
    city: String?,
    state: String?,
    country: String?,
    postalCode: String?,
    phone: String?,
    fax: String?,
    email: String,
    supportRepresentative: Employee?,
  ) {
    self.chinookId = chinookId
    self.firstName = firstName
    self.lastName = lastName
    self.company = company
    self.address = address
    self.city = city
    self.state = state
    self.country = country
    self.postalCode = postalCode
    self.phone = phone
    self.fax = fax
    self.email = email
    self.supportRepresentative = supportRepresentative
  }
}
