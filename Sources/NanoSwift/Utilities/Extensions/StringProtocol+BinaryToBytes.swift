//
//  StringProtocol+BinaryToBytes.swift
//  
//
//  Created by Christian Privitelli on 7/3/21.
//

import Foundation

extension StringProtocol {
    public var binaryToBytes: Bytes { .init(binary) }
    private var binary: UnfoldSequence<Byte, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 8, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return Byte(self[startIndex..<endIndex], radix: 2)
        }
    }
}
