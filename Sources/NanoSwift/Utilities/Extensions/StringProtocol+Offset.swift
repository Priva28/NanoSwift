//
//  StringProtocol+Offset.swift
//  
//
//  Created by Christian Privitelli on 7/3/21.
//

extension StringProtocol {
    public subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
