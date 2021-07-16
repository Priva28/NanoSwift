//
//  NanoAmount.swift
//  
//
//  Created by Christian Privitelli on 23/3/21.
//

import Foundation

/// A type that lets you easily create and represent nano amounts and balances. This type lets you convert between raw and NANO/Nano/Mnano units and can be represented as `NSDecimalNumber`s or `String`s
public struct NanoAmount {
    
    public init(raw: String) {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        if let value = formatter.number(from: raw) as? NSDecimalNumber {
            self.rawAmount = value
        } else {
            self.rawAmount = 0
        }
    }
    
    public init(amount: NSDecimalNumber) {
        self.rawAmount = amount.multiplying(byPowerOf10: 30)
    }
    
    private init(raw: NSDecimalNumber) {
        self.rawAmount = raw
    }
    
    /// The amount represented in nano raw as a `NSDecimalNumber`. This value is the base value of this type and everything is converted from this. This is 10^30 of a regular NANO/Nano/Mnano value.
    public var rawAmount: NSDecimalNumber
    
    /// The nanoAmount converts the rawAmount to a NANO/Nano/Mnano amount commonly used in most wallets as an `NSDecimalNumber`.
    public var nanoAmount: NSDecimalNumber {
        let divider = NSDecimalNumber(mantissa: 1, exponent: 30, isNegative: false)
        return rawAmount.dividing(by: divider)
    }
    
    /// The nanoAmount represented as a `String`.
    public var nanoString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.roundingMode = .halfUp
        numberFormatter.maximumFractionDigits = 5

        guard let result = numberFormatter.string(from: nanoAmount) else { return "0" }
        return result
    }
    
    /// The rawAmount represented as a `String`.
    public var rawString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent

        guard let result = numberFormatter.string(from: rawAmount) else { return "0" }
        return result
    }
    
    /// Full credit for this method goes to **vacawama** on StackOverflow.
    /// https://stackoverflow.com/questions/30762414/swift-convert-decimal-string-to-uint8-array
    public var rawBytes: Bytes {
        // Convert input string into array of Int digits
        let digits = Array(rawString).compactMap { Int(String($0)) }

        // Nothing to process? Return an empty array.
        guard digits.count > 0 else { return [] }

        let numdigits = digits.count

        // Array to hold the result, in reverse order
        var bytes = Bytes()

        // Convert array of digits into array of Int values each
        // representing 6 digits of the original number.  Six digits
        // was chosen to work on 32-bit and 64-bit systems.
        // Compute length of first number.  It will be less than 6 if
        // there isn't a multiple of 6 digits in the number.
        var ints = Array(repeating: 0, count: (numdigits + 5)/6)
        var rem = numdigits % 6
        if rem == 0 {
            rem = 6
        }
        var index = 0
        var accum = 0
        for digit in digits {
            accum = accum * 10 + digit
            rem -= 1
            if rem == 0 {
                rem = 6
                ints[index] = accum
                index += 1
                accum = 0
            }
        }

        // Repeatedly divide value by 256, accumulating the remainders.
        // Repeat until original number is zero
        while ints.count > 0 {
            var carry = 0
            for (index, value) in ints.enumerated() {
                var total = carry * 1000000 + value
                carry = total % 256
                total /= 256
                ints[index] = total
            }

            bytes.append(Byte(truncatingIfNeeded: carry))

            // Remove leading Ints that have become zero.
            while ints.count > 0 && ints[0] == 0 {
                ints.remove(at: 0)
            }
        }

        // Reverse the array and return it
        return bytes.reversed()
    }
}

/// ** NanoAmount Operators **

extension NanoAmount {
    static public func <=(lhs: NanoAmount, rhs: NanoAmount) -> Bool {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return lhsRaw.compare(rhsRaw) == .orderedAscending || lhsRaw.compare(rhsRaw) == .orderedSame
    }
    
    static public func <(lhs: NanoAmount, rhs: NanoAmount) -> Bool {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return lhsRaw.compare(rhsRaw) == .orderedAscending
    }
    
    static public func >=(lhs: NanoAmount, rhs: NanoAmount) -> Bool {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return lhsRaw.compare(rhsRaw) == .orderedDescending || lhsRaw.compare(rhsRaw) == .orderedSame
    }
    
    static public func >(lhs: NanoAmount, rhs: NanoAmount) -> Bool {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return lhsRaw.compare(rhsRaw) == .orderedDescending
    }
    
    static public func ==(lhs: NanoAmount, rhs: NanoAmount) -> Bool {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return lhsRaw.compare(rhsRaw) == .orderedSame
    }
    
    static public func !=(lhs: NanoAmount, rhs: NanoAmount) -> Bool {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return lhsRaw.compare(rhsRaw) != .orderedSame
    }
    
    static public func +(lhs: NanoAmount, rhs: NanoAmount) -> NanoAmount {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return NanoAmount(raw: lhsRaw.adding(rhsRaw))
    }
    
    static public func -(lhs: NanoAmount, rhs: NanoAmount) -> NanoAmount {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return NanoAmount(raw: lhsRaw.subtracting(rhsRaw))
    }
    
    static public func *(lhs: NanoAmount, rhs: NanoAmount) -> NanoAmount {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return NanoAmount(raw: lhsRaw.multiplying(by: rhsRaw))
    }
    
    static public func *(lhs: NanoAmount, rhs: Int) -> NanoAmount {
        let lhsRaw = lhs.rawAmount
        return NanoAmount(raw: lhsRaw.multiplying(by: NSDecimalNumber(value: rhs)))
    }
    
    static public func /(lhs: NanoAmount, rhs: NanoAmount) -> NanoAmount {
        let lhsRaw = lhs.rawAmount
        let rhsRaw = rhs.rawAmount
        return NanoAmount(raw: lhsRaw.dividing(by: rhsRaw))
    }
    
    static public func /(lhs: NanoAmount, rhs: Int) -> NanoAmount {
        let lhsRaw = lhs.rawAmount
        return NanoAmount(raw: lhsRaw.dividing(by: NSDecimalNumber(value: rhs)))
    }
}
