//
//  Bytes+HexString.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

extension Bytes {
    /// To be used if the bytes array is hex data. Return the data as a hex encoded string.
    public var hexString: String {
        var hexString: String = ""
        var count = self.count
        for byte in self {
            hexString.append(String(format:"%02X", byte))
            count = count - 1
        }
        return hexString
    }
}
