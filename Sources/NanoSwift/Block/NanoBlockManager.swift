//
//  NanoBlockManager.swift
//  
//
//  Created by Christian Privitelli on 20/3/21.
//

public class NanoBlockManager {
    
    internal init(blockFunctions: NanoBlockFunctions, accountFunctions: NanoAccountFunctions) {
        self.functions = blockFunctions
        self.accountFunctions = accountFunctions
    }
    
    public let functions: NanoBlockFunctions
    private let accountFunctions: NanoAccountFunctions
    
    public func sendBlock(from sendingAccount: NanoAccount, to recievingAddress: String, amount: NanoAmount) throws -> NanoStateBlock {
        guard let frontier = sendingAccount.accountInfo?.frontier else { throw NanoBlockManagerError.noFrontier }
        guard let representative = sendingAccount.accountInfo?.representative else { throw NanoBlockManagerError.noRepresentative }
        guard amount <= sendingAccount.balance else { throw NanoBlockManagerError.sendingAccountLowBalance }
        
        guard let recievingAccountSplit = accountFunctions.splitAddress(address: recievingAddress) else { throw NanoBlockManagerError.couldNotConvertRecievingAddress }
        let encoded = recievingAccountSplit.1.0
        guard let recievingPublicKey = accountFunctions.decodePublicKey(from: encoded) else { throw NanoBlockManagerError.couldNotConvertRecievingAddress }
        
        var block = NanoStateBlock(
            previous: frontier,
            account: sendingAccount.publicAddress,
            representative: representative,
            balance: sendingAccount.balance - amount,
            link: String(recievingPublicKey.binaryToBytes.hexString.dropFirst(2))
        )
        
        guard let hash = functions.hashStateBlock(from: block).optional else { throw NanoBlockManagerError.otherError }
        block.hash = hash
        block.signature = functions.signStateBlockHash(hash: hash, privateKey: sendingAccount.privateKey)
        
        return block
    }
    
    public func sendBlock(from sendingAccount: NanoAccount, to recievingAccount: NanoAccount, amount: NanoAmount) throws -> NanoStateBlock {
        return try sendBlock(from: sendingAccount, to: recievingAccount.publicAddress, amount: amount)
    }
    
    public func receiveBlock(for account: NanoAccount, with hash: String, amount: NanoAmount) throws -> NanoStateBlock {
        guard let frontier = account.accountInfo?.frontier else { throw NanoBlockManagerError.noFrontier }
        guard let representative = account.accountInfo?.representative else { throw NanoBlockManagerError.noRepresentative }
        
        var block = NanoStateBlock(
            previous: frontier,
            account: account.publicAddress,
            representative: representative,
            balance: account.balance+amount,
            link: hash
        )
        
        guard let hash = functions.hashStateBlock(from: block).optional else { throw NanoBlockManagerError.otherError }
        block.hash = hash
        block.signature = functions.signStateBlockHash(hash: hash, privateKey: account.privateKey)
        
        return block
    }
    
    public func receiveBlock(for account: NanoAccount, with pendingBlock: NanoPendingBlock) throws -> NanoStateBlock {
        return try receiveBlock(for: account, with: pendingBlock.hash, amount: pendingBlock.amount)
    }
}

public enum NanoBlockManagerError: Error {
    case noFrontier
    case noRepresentative
    case sendingAccountLowBalance
    case couldNotConvertRecievingAddress
    case otherError
}
