//
//  NanoAccountFunctions.swift
//  
//
//  Created by Christian Privitelli on 26/3/21.
//

import Monocypher

public class NanoAccountFunctions {
    
    internal init() {}
    
    let encoder = NanoEncoder()
    
    /// Add the given index to the end of the given seed and hash into a 32 byte private key using the Blake2b private key derivation path.
    ///
    /// See  [Nano Seed Docs](https://docs.nano.org/integration-guides/the-basics/#seed) and [Nano Hashing Algorithm Docs](https://docs.nano.org/protocol-design/signing-hashing-and-key-derivation/#hashing-algorithm-blake2) for more information.
    /// - Parameter seed: Derive private key from given seed.
    /// - Parameter index: Derive the private key with index. This index will determine the final account address.
    public func derivePrivateKey(from seed: Bytes, index: UInt32) -> Bytes {
        // Add the index to the end of the seed.
        let seedWithIndex = seed+index.bytes
        
        // The resulting private key will be written to this property.
        var privateKey = Bytes(repeating: 0, count: 32)
        
        privateKey.withUnsafeMutableBufferPointer { buffer in
            // This is using the Blake2b hash method.
            // Hash the seed+index to retrieve the private key.
            crypto_blake2b_general(buffer.baseAddress, 32, nil, 0, seedWithIndex, seedWithIndex.count)
        }
        
        return privateKey
    }
    
    /// Use the ED25519 signing algorithm with a Blake2b derivation method to generate the public key.
    ///
    /// See [Nano Public Key Docs](https://docs.nano.org/integration-guides/the-basics/#account-public-key) and [Nano Signing Algorithm Docs](https://docs.nano.org/protocol-design/signing-hashing-and-key-derivation/#signing-algorithm-ed25519) for more information.
    /// - Parameter privateKey: Derive public key from given private key.
    public func derivePublicKey(from privateKey: Bytes) -> Bytes {
        // The resulting public key will be written to this property.
        var publicKey = Bytes(repeating: 0, count: 32)
        
        publicKey.withUnsafeMutableBufferPointer { buffer in
            // This is using the 25519 curve and the Blake2b hash method.
            // Sign the private key and in turn, create the public key.
            crypto_sign_public_key(buffer.baseAddress, privateKey)
        }
        
        return publicKey
    }
    
    /// Encode the public key with a specific Base32 encoding for a Nano address.
    ///
    /// See [Nano Docs](https://docs.nano.org/integration-guides/the-basics/#account-public-address) for more information.
    /// - Parameter publicKey: Public key to be encoded.
    public func encodePublicKey(from publicKey: Bytes) -> String? {
        return encoder.base32NanoEncode(message: publicKey, binaryLength: 260)
    }
    
    /// Decode an encoded public key that would normally be in a Nano or Banano address. Returns as binary.
    ///
    /// - Parameter encodedPublicKey: Encoded public key to be decoded.
    public func decodePublicKey(from encodedPublicKey: String) -> String? {
        return encoder.base32NanoDecode(message: encodedPublicKey)
    }
    
    /// Hash the public key into a 5 byte array using the Blake2b algorithm then encode the result with a specific Base32 encoding for a Nano address.
    ///
    /// See [Nano Docs](https://docs.nano.org/integration-guides/the-basics/#account-public-address) for more information.
    /// - Parameter publicKey: Public key to create checksum from.
    public func createChecksum(from publicKey: Bytes) -> String? {
        // The resulting public key will be written to this property.
        var checksum = Bytes(repeating: 0, count: 5)
        
        checksum.withUnsafeMutableBufferPointer { buffer in
            // This is using the Blake2b hash method.
            // Hash the public key to retrieve the checksum.
            crypto_blake2b_general(buffer.baseAddress, 5, nil, 0, publicKey, publicKey.count)
        }
        
        return encoder.base32NanoEncode(message: checksum.reversed(), binaryLength: 40)
    }
    
    /// Check if given address is valid. Returns true if it is, returns false if it is not.
    /// - Parameter address: The address to check.
    public func checkIfAddressIsValid(address: String) -> AddressCheckResult {
        
        // Split the address. If that fails, return false as the address is invalid.
        guard let splitAddress = splitAddress(address: address) else { return .invalidPrefix }
        let encodedPublicKey = splitAddress.1.0
        let expectedChecksum = splitAddress.1.1
        
        // Check if address matches nano regex.
        // If it doesn't return the issue as the address is invalid.
        // https://docs.nano.org/integration-guides/the-basics/#account-public-address
        // Modified to support banano.
        let regex = "^(nano|xrb|ban)_[13]{1}[13456789abcdefghijkmnopqrstuwxyz]{59}$"
        if address.range(of: regex, options: .regularExpression, range: nil, locale: nil) == nil {
            if encodedPublicKey.first != "1" && encodedPublicKey.first != "3" {
                return .invalidEncoding
            } else if encodedPublicKey.count + expectedChecksum.count != 60 {
                return .invalidLength
            } else {
                return .invalidOther
            }
        }
        
        // Try to decode the public key. If that fails return false.
        guard let publicKey = decodePublicKey(from: encodedPublicKey) else { return .invalidEncoding }
        
        // TODO: This feels hacky and bad but works. CHeck why this is required.
        let publicKeyBytes = publicKey.binaryToBytes.hexString.dropFirst(2).hexToBytes

        // Test if checksum in address matches the checksum created from the now decoded public key.
        let checksum = createChecksum(from: publicKeyBytes)
        if expectedChecksum != checksum {
            return .invalidChecksum
        }
        return .valid
    }
    
    public enum AddressCheckResult {
        case valid
        case invalidLength
        case invalidEncoding
        case invalidChecksum
        case invalidPrefix
        case invalidOther
    }
    
    /// Split an addresses prefix, encoded public key and checksum.
    ///
    /// Getting the prefix:
    ///
    /// `splitAddress().0.rawValue`
    ///
    /// Getting the encoded public key:
    ///
    /// `splitAddress().1.0`
    ///
    /// Getting the checksum:
    ///
    /// `splitAddress().1.1`
    /// - Returns: Returns a tuple containing the account type and another tuple which contains the encoded public key and checksum.
    /// - Parameter address: The Nano or Banano address to split. Prefix must be `nano_`, `xrb_` or `ban_`.
    public func splitAddress(address: String) -> (NanoAccountPrefix, (String, String))? {
        guard address.contains("nano_") || address.contains("xrb_") || address.contains("ban_") else { return nil }
        let addressNoChecksum = String(address.dropLast(8))
        let checksum = String(address.suffix(8))
        switch String(addressNoChecksum.prefix(4)) {
        case "nano":
            return (.nano, (String(addressNoChecksum.dropFirst(5)), checksum))
        case "xrb_":
            return (.xrb, (String(addressNoChecksum.dropFirst(4)), checksum))
        case "ban_":
            return (.banano, (String(addressNoChecksum.dropFirst(4)), checksum))
        default:
            return nil
        }
    }
}
