//
//  NanoWalletManager.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

import Foundation

public class NanoWalletManager {
    public let functions: NanoWalletFunctions
    private let accounts: NanoAccountManager
    
    internal init(walletFunctions: NanoWalletFunctions, accountManager: NanoAccountManager) {
        self.functions = walletFunctions
        self.accounts = accountManager
    }
    
    /// Create a new Nano wallet. A seed is automatically generated.
    /// - Parameter withBaseAccount: If this value is  `false` the wallet will be empty. Otherwise an account with index 0 will be automatically generated. Defaults to `true`.
    /// - Returns a `NanoWallet` struct. This contains the seed as well as a list of accounts.
    public func newWallet(seed: Bytes? = nil, withBaseAccount: Bool = true, type: NanoType = .nano) -> NanoWallet {
        let seed = seed ?? functions.generateWalletSeed()
        var wallet = NanoWallet(seed: seed)
        if withBaseAccount, let account = try? accounts.newAccount(from: seed, index: 0, type: type) {
            try? wallet.accounts.append(account: account)
        }
        
        return wallet
    }
}
