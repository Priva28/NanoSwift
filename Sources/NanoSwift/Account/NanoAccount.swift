//
//  NanoAccount.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

public struct NanoAccount {
    
    public init(index: UInt32, privateKey: Bytes, publicKey: Bytes, type: NanoType = .nano, encodedPublicKey: String, endodedChecksum: String) {
        self.index = index
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.type = type
        if type == .nano {
            self.prefix = .nano
        } else {
            self.prefix = .banano
        }
        self.encodedPublicKey = encodedPublicKey
        self.endodedChecksum = endodedChecksum
    }
    
    public init(index: UInt32, privateKey: Bytes, publicKey: Bytes, prefix: NanoAccountPrefix, encodedPublicKey: String, endodedChecksum: String) {
        self.index = index
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.prefix = prefix
        if prefix == .nano || prefix == .xrb {
            self.type = .nano
        } else {
            self.type = .banano
        }
        self.encodedPublicKey = encodedPublicKey
        self.endodedChecksum = endodedChecksum
    }
    
    /// The index number of the account. This can be anything from 0 to 2³²-1.
    public var index: UInt32
    
    /// The account private key derived from the hash of the seed and index. Used for signing state block hashes.
    public var privateKey: Bytes
    
    /// The account public key derived from signing the public key.
    /// This is a "raw" version of your public address that can be used when creating blocks.
    public var publicKey: Bytes
    
    /// The prefix of your public address. Valid values are `.banano`, `.nano` and `.xrb`.
    /// `.xrb` should not be used for creating a new account unless it is to represent an older account for whatever reason.
    public var prefix: NanoAccountPrefix
    
    /// The type of nano used. Can either be `.nano` or `.banano`.
    public var type: NanoType
    
    /// The public address constructed with the prefix, an encoded version of the public key for readability and an encoded checksum.
    /// This is the address users can share their Nano with each other.
    ///
    /// - Example: `nano_1hdda1zcipzftncz155ughx5xzyunsjxygbyc6yqjqoz9emmanzc8qybmubs`
    public var publicAddress: String {
        return prefix.rawValue + encodedPublicKey + endodedChecksum
    }
    
    /// The balance of the account. This value is gathered from the account info balance as a raw string.
    /// Account info should be populated from the `account_info` RPC command from a node.
    /// If this doesn't exist, the balance is 0.
    public var balance: NanoAmount {
        return NanoAmount(raw: accountInfo?.balance ?? "0")
    }
    
    /// Encoded public key used in the public address.
    public var encodedPublicKey: String
    
    /// Checksum used in the public address.
    public var endodedChecksum: String
    
    public var accountInfo: NanoAccountInfo? = nil
}
