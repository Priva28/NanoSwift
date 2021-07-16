//
//  NanoStateBlock.swift
//  
//
//  Created by Christian Privitelli on 18/3/21.
//

public struct NanoStateBlock {
    public init(type: String = "state", previous: String, account: String, representative: String, balance: NanoAmount, link: String, work: String? = nil, hash: Bytes? = nil, signature: Bytes? = nil) {
        self.type = type
        self.previous = previous
        self.account = account
        self.representative = representative
        self.balance = balance
        self.link = link
        self.hash = hash
        self.work = work
        self.signature = signature
    }
    
    public var type: String = "state"
    public var previous: String
    public var account: String
    public var representative: String
    public var balance: NanoAmount
    public var link: String
    public var work: String?
    
    public var hash: Bytes? = nil
    public var signature: Bytes? = nil
}

