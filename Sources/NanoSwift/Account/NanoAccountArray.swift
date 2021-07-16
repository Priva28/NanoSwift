//
//  NanoAccountArray.swift
//  
//
//  Created by Christian Privitelli on 14/7/21.
//

public struct NanoAccountArray {
    private var accounts: [NanoAccount]
    
    public init() {
        self.accounts = []
    }
    
    public subscript(index: UInt32) -> NanoAccount? {
        return accounts.first(where: { $0.index == index })
    }
    
    public mutating func append(account: NanoAccount) throws {
        if !accounts.contains(where: { $0.index == account.index }) {
            accounts.append(account)
        } else {
            throw NanoAccountManagerError.indexAlreadyExists
        }
    }
    
    public mutating func remove(index: UInt32) {
        accounts.removeAll(where: { $0.index == index })
    }
    
    public func contains(index: UInt32) -> Bool {
        return accounts.contains(where: { $0.index == index })
    }
    
    public func lastIndex() -> Int {
        if accounts.isEmpty {
            return -1
        } else {
            return Int(accounts.sorted(by: { $1.index > $0.index }).last!.index)
        }
    }
}
