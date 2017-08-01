import Foundation

public protocol HashableUsingAddress:class, Hashable {
}

extension HashableUsingAddress {
  /**
    Compares two GenericProperty to see if they are equal.
    - Prameter left: The left GenericProperty to compare.
    - Prameter right: The right GenericProperty to compare.
    - Returns: True if the GenericProperties are equal.
  */
  public static func == (left: Self, right: Self) -> Bool {
      return left === right
  }

  /**
    Calculates the hashValue of the GenericProperty.
    - Returns: The hashValue of the GenericProperty.
  */
  public var hashValue: Int {
    get {
      return ObjectIdentifier(self).hashValue
    }
  }
}
