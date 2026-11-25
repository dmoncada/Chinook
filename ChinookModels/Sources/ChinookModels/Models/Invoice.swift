import Foundation
import SwiftData

@Model
public nonisolated final class Invoice {
  @Attribute(.unique)
  public var chinookId: Int
  public var customer: Customer
  public var invoiceDate: Date
  public var billingAddress: String?
  public var billingCity: String?
  public var billingState: String?
  public var billingCountry: String?
  public var billingPostalCode: String?
  public var totalInCents: Int

  init(
    chinookId: Int,
    customer: Customer,
    invoiceDate: Date,
    billingAddress: String?,
    billingCity: String?,
    billingState: String?,
    billingCountry: String?,
    billingPostalCode: String?,
    totalInCents: Int,
  ) {
    self.chinookId = chinookId
    self.customer = customer
    self.invoiceDate = invoiceDate
    self.billingAddress = billingAddress
    self.billingCity = billingCity
    self.billingState = billingState
    self.billingCountry = billingCountry
    self.billingPostalCode = billingPostalCode
    self.totalInCents = totalInCents
  }
}
