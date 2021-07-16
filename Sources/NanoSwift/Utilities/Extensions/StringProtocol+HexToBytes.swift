//
//  StringProtocol+HexToBytes.swift
//  
//
//  Created by Christian Privitelli on 7/3/21.
//

extension StringProtocol {
    public var hexToBytes: Bytes { .init(hex) }
    private var hex: UnfoldSequence<Byte, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return Byte(self[startIndex..<endIndex], radix: 16)
        }
    }
}


