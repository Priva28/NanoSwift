//
//  NanoWalletFunctions.swift
//  
//
//  Created by Christian Privitelli on 26/3/21.
//

import Foundation
import Monocypher

public class NanoWalletFunctions {
    
    internal init() {}
    
    /// Generate a secure 32 byte long random seed that can be used for a Nano wallet.
    public func generateWalletSeed() -> Bytes {
        var seed = Bytes(repeating: 0, count: 32)
        let _ = SecRandomCopyBytes(kSecRandomDefault, 32, &seed)
        return seed
    }
    
    public func generateWalletSeed(message: String) -> Bytes {
        let messageBytes = Bytes(message.utf8)
        
        // The resulting private key will be written to this property.
        var seed = Bytes(repeating: 0, count: 32)
        
        seed.withUnsafeMutableBufferPointer { buffer in
            // This is using the Blake2b hash method.
            // Hash the seed+index to retrieve the private key.
            crypto_blake2b_general(buffer.baseAddress, 32, nil, 0, messageBytes, messageBytes.count)
        }
        
        return seed
    }
}

