//
//  NanoAccountManager.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

import Foundation

public class NanoAccountManager {
    
    internal init(accountFunctions: NanoAccountFunctions) {
        self.functions = accountFunctions
    }
    
    public let functions: NanoAccountFunctions
    
    /// Create a new account with index derived from some seed.
    public func newAccount(from seed: Bytes, index: UInt32, type: NanoType = .nano) throws -> NanoAccount {
        let privateKey = functions.derivePrivateKey(from: seed, index: index)
        let publicKey = functions.derivePublicKey(from: privateKey)
        guard let encodedPublicKey = functions.encodePublicKey(from: publicKey) else { throw NanoAccountManagerError.otherError }
        guard let checksum = functions.createChecksum(from: publicKey) else { throw NanoAccountManagerError.otherError }
        
        return NanoAccount(
            index: index,
            privateKey: privateKey,
            publicKey: publicKey,
            type: type,
            encodedPublicKey: encodedPublicKey,
            endodedChecksum: checksum
        )
    }
    
    /// Create a new account with index for a certain wallet.
    public func newAccount(for wallet: NanoWallet, index: UInt32? = nil) throws -> NanoAccount {
        // If index is not provided, continue counting from existing accounts.
        let accountIndex = wallet.accounts.lastIndex() + 1
        
        // Check if an account at that index already exists in the given wallet.
        guard !wallet.accounts.contains(index: UInt32(accountIndex))
            else { throw NanoAccountManagerError.indexAlreadyExists }
        guard let account = try? newAccount(from: wallet.seed, index: UInt32(accountIndex), type: wallet.type)
            else { throw NanoAccountManagerError.otherError }
        
        return account
    }
    
    /// Add a new account with index to a certain wallet.
    public func newAccount(into wallet: inout NanoWallet, index: UInt32? = nil) throws {
        // If index is not provided, continue counting from existing accounts.
        let accountIndex = wallet.accounts.lastIndex() + 1
        
        // Check if an account at that index already exists in the given wallet.
        guard let account = try? newAccount(from: wallet.seed, index: UInt32(accountIndex), type: wallet.type)
            else { throw NanoAccountManagerError.otherError }
        
        try wallet.accounts.append(account: account)
    }
}

public enum NanoAccountManagerError: Error {
    case indexAlreadyExists
    case otherError
}
