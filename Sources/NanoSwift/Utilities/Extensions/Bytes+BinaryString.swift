//
//  Bytes+BinaryString.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

extension Bytes {
    /// Return data in bytes array as binary in a string format.
    public func binaryString(length: Int) -> String {
        let unformatted = self.map {
            let binary = String($0, radix: 2)
            return repeatElement("0", count: 8-binary.count) + binary
        }.joined()
        return String(repeating: "0", count: Swift.max(0, length-unformatted.count)) + unformatted
    }
}
