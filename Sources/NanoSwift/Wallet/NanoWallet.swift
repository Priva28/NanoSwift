//
//  NanoWallet.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

public struct NanoWallet {
    public init(seed: Bytes) {
        self.seed = seed
        self.accounts = NanoAccountArray()
    }
    
    public let seed: Bytes
    public let type: NanoType = .nano
    public var accounts: NanoAccountArray
}
