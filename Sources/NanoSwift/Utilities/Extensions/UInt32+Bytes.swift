//
//  UInt32+Bytes.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

extension UInt32 {
    /// Convert 32-bit unsigned integer to UInt8 array. `Bytes` is a alias for `Array<UInt8>`
    public var bytes: Bytes {
        return withUnsafeBytes(of: self.bigEndian, Array.init)
    }
}
