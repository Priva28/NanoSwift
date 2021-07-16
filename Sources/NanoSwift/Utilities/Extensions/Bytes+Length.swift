//
//  Bytes+Length.swift
//  
//
//  Created by Christian Privitelli on 25/3/21.
//

extension Bytes {
    public func length(_ length: Int) -> Bytes {
        guard self.count < length else { return self }
        var result = self
        while result.count != length {
            result.insert(0, at: 0)
        }
        return result
    }
}
