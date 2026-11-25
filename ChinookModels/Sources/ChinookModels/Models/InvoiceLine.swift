import SwiftData

@Model
public nonisolated final class InvoiceLine {
  @Attribute(.unique)
  public var chinookId: Int
  public var invoice: Invoice
  public var track: Track
  public var unitPriceInCents: Int
  public var quantity: Int

  init(
    chinookId: Int,
    invoice: Invoice,
    track: Track,
    unitPriceInCents: Int,
    quantity: Int,
  ) {
    self.chinookId = chinookId
    self.invoice = invoice
    self.track = track
    self.unitPriceInCents = unitPriceInCents
    self.quantity = quantity
  }
}
