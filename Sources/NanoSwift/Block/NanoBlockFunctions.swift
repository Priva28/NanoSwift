//
//  NanoBlockFunctions.swift
//  
//
//  Created by Christian Privitelli on 26/3/21.
//

import Monocypher

public class NanoBlockFunctions {
    
    internal init(accountFunctions: NanoAccountFunctions) {
        self.accountFunctions = accountFunctions
    }
    
    private let accountFunctions: NanoAccountFunctions
    
    public func hashStateBlock(from block: NanoStateBlock) -> HashStateBlockResult {
        func makeHex(_ address: String) -> String? {
            switch address.prefix(4) {
            case "nano", "ban_", "xrb_":
                let split = accountFunctions.splitAddress(address: address)
                guard let decoded = accountFunctions.decodePublicKey(from: split!.1.0) else { return nil }
                // TODO: Also check why this is required
                let decodedString = String(decoded.binaryToBytes.hexString.dropFirst(2))
                guard decodedString.count == 64 else { return nil }
                return decodedString
            default:
                guard address.count == 64 else { return nil }
                return address
            }
        }
        
        guard let hexAccount = makeHex(block.account) else { return .invalidAccount }
        guard block.previous.count == 64 || block.previous == "0" else { return .invalidPrevious }
        guard let hexRep = makeHex(block.representative) else { return .invalidRepresentative }
        guard let hexLink = makeHex(block.link) else { return .invalidLink }
        
        let statePreamble = "6".hexToBytes.length(32)
        let account = hexAccount.hexToBytes.length(32)
        let previous = block.previous.hexToBytes.length(32)
        let representative = hexRep.hexToBytes.length(32)
        let balance = block.balance.rawBytes.length(16)
        let link = hexLink.hexToBytes.length(32)
        
        let unhashed = statePreamble+account+previous+representative+balance+link
        
        // The resulting public key will be written to this property.
        var hash = Bytes(repeating: 0, count: 32)
        
        hash.withUnsafeMutableBufferPointer { buffer in
            // This is using the Blake2b hash method.
            // Hash the seed+index to retrieve the private key.
            crypto_blake2b_general(buffer.baseAddress, 32, nil, 0, unhashed, unhashed.count)
        }
        
        return .success(hash)
    }
    
    public enum HashStateBlockResult {
        case success(Bytes)
        case invalidAccount
        case invalidPrevious
        case invalidRepresentative
        case invalidLink
        
        public var optional: Bytes? {
            switch self {
            case .success(let success):
                return success
            default:
                return nil
            }
        }
        
        public var forceUnwrap: Bytes {
            switch self {
            case .success(let success):
                return success
            default:
                fatalError("Tried to access hash state block result that failed or didn't exist.")
            }
        }
    }
    
    public func signStateBlockHash(hash: Bytes, privateKey: Bytes, publicKey: Bytes? = nil) -> Bytes {
        let publicKey = publicKey ?? accountFunctions.derivePublicKey(from: privateKey)
        var signature = Bytes(repeating: 0, count: 64)
        signature.withUnsafeMutableBufferPointer { buffer in
            // This is using the 25519 curve and the Blake2b hash method.
            // Sign the hash with the private and public key.
            crypto_sign(buffer.baseAddress, privateKey, publicKey, hash, 32)
        }
        return signature
    }
}
