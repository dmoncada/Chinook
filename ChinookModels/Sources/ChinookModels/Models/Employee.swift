import Foundation
import SwiftData

@Model
public nonisolated final class Employee {
  @Attribute(.unique)
  public var chinookId: Int
  public var lastName: String
  public var firstName: String
  public var title: String?
  public var birthDate: Date?
  public var hireDate: Date?
  public var address: String?
  public var city: String?
  public var state: String?
  public var country: String?
  public var postalCode: String?
  public var phone: String?
  public var fax: String?
  public var email: String?
  public var manager: Employee?

  @Relationship(inverse: \Employee.manager)
  public var directReports: [Employee] = []

  init(
    chinookId: Int,
    lastName: String,
    firstName: String,
    title: String?,
    birthDate: Date?,
    hireDate: Date?,
    address: String?,
    city: String?,
    state: String?,
    country: String?,
    postalCode: String?,
    phone: String?,
    fax: String?,
    email: String?,
  ) {
    self.chinookId = chinookId
    self.lastName = lastName
    self.firstName = firstName
    self.title = title
    self.birthDate = birthDate
    self.hireDate = hireDate
    self.address = address
    self.city = city
    self.state = state
    self.country = country
    self.postalCode = postalCode
    self.phone = phone
    self.fax = fax
    self.email = email
  }
}
