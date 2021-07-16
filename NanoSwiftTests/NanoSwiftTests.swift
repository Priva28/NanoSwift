//
//  NanoSwiftTests.swift
//  
//
//  Created by Christian Privitelli on 7/3/21.
//

import XCTest
import NanoSwift
 
class NanoSwiftTests: XCTestCase {
    let nano = Nano()
    
    /// # Test conversions
    
    func testHexAndBytes() {
        let hex = "780AC2195BC676FFD653C9F99FE641C9BB45B6E077CFAC5B6161461AC9C981AA"
        let bytes: Bytes = [120, 10, 194, 25, 91, 198, 118, 255, 214, 83, 201, 249, 159, 230, 65, 201, 187, 69, 182, 224, 119, 207, 172, 91, 97, 97, 70, 26, 201, 201, 129, 170]
        // Hex string to bytes.
        XCTAssertEqual(hex.hexToBytes, bytes)
        // Byte array to hex string.
        XCTAssertEqual(bytes.hexString, hex)
        // back and forth
        XCTAssertEqual(hex.hexToBytes.hexString, hex)
    }
    
    func testBinaryAndBytes() {
        let binary = "011001101110000100100100"
        let binary2 = "000000011001101110000100100100"
        let bytes: Bytes = [102, 225, 36]
        // Binary string to bytes.
        XCTAssertEqual(binary.binaryToBytes, bytes)
        // Byte array to binary string with length of 24.
        XCTAssertEqual(bytes.binaryString(length: 24), binary)
        // Different length
        XCTAssertEqual(bytes.binaryString(length: 30), binary2)
    }
    
    func testUInt32Bytes() {
        let bytes: Bytes = [0, 0, 4, 210]
        XCTAssertEqual(UInt32(1234).bytes, bytes)
    }
    
    func testBytesLength() {
        let bytes: Bytes = [8, 8, 8]
        let result: Bytes = [0, 0, 0, 8, 8, 8]
        XCTAssertEqual(bytes.length(6), result)
    }
    
    /// # Test NanoAmount
    
    func testNanoToRaw() {
        let nano = NanoAmount(amount: 1.39)
        let raw = NSDecimalNumber(string: "1390000000000000000000000000000")
        XCTAssertEqual(nano.rawAmount, raw)
    }
    
    func testRawToNano() {
        let raw = NanoAmount(raw: "1800000000000000000000000000000")
        let nano = NSDecimalNumber(1.8)
        XCTAssertEqual(raw.nanoAmount, nano)
    }
    
    func testNanoString() {
        let nano = NanoAmount(raw: "22500000000000000000000000000000")
        let string1 = "22.5"
        let string2 = "22,5"
        XCTAssertTrue(nano.nanoString == string1 || nano.nanoString == string2)
    }
    
    func testRawString() {
        let nano = NanoAmount(raw: "20100000000000000000000000000000")
        let raw = "20100000000000000000000000000000"
        XCTAssertEqual(nano.rawString, raw)
    }
    
    /// - TODO: Test raw bytes from NanoAmount
    
    func testNanoAmountOperators() {
        XCTAssertTrue(NanoAmount(amount: 1) > NanoAmount(amount: 0.9))
        XCTAssertTrue(NanoAmount(amount: 1) < NanoAmount(amount: 1.1))
        XCTAssertTrue(NanoAmount(amount: 1) >= NanoAmount(amount: 1))
        XCTAssertTrue(NanoAmount(amount: 1) >= NanoAmount(amount: 0.9))
        XCTAssertTrue(NanoAmount(amount: 1) <= NanoAmount(amount: 1))
        XCTAssertTrue(NanoAmount(amount: 1) <= NanoAmount(amount: 1.1))
        XCTAssertTrue(NanoAmount(amount: 1) == NanoAmount(amount: 1))
        XCTAssertTrue(NanoAmount(amount: 1) + NanoAmount(amount: 1) == NanoAmount(amount: 2))
        XCTAssertTrue(NanoAmount(amount: 2) - NanoAmount(amount: 1) == NanoAmount(amount: 1))
        XCTAssertTrue(NanoAmount(raw: "2") * NanoAmount(raw: "2") == NanoAmount(raw: "4"))
        XCTAssertTrue(NanoAmount(amount: 2) * 2 == NanoAmount(amount: 4))
        XCTAssertTrue(NanoAmount(raw: "8") / NanoAmount(raw: "2") == NanoAmount(raw: "4"))
        XCTAssertTrue(NanoAmount(amount: 8) / 2 == NanoAmount(amount: 4))
    }
    
    /// # Test Account Functions
    
    func testSeedToPrivateKey() {
        let seed = "AF30153E697BCF976236C68995774AA0797B8D67E46DDC15E1694317DA03BF84".hexToBytes
        let privateKey0 = "4B1BA284ABB8CD984747E4842BC516CD98EF5266DF71D4FD794DA1A91F49CAB1".hexToBytes
        let privateKey10 = "1181391DC2548DFC41205008D7C1B118D7AC3452CD29A68D2732E6B5BA3802A6".hexToBytes
        XCTAssertEqual(nano.accounts.functions.derivePrivateKey(from: seed, index: 0), privateKey0)
        XCTAssertEqual(nano.accounts.functions.derivePrivateKey(from: seed, index: 10), privateKey10)
    }
    
    func testPrivateKeyToPublicKey() {
        let privateKey = "28C5154368F447EADD9B34C76A5F69BBE2BB90DFA0ECC73A0DD66191129A697F".hexToBytes
        let publicKey = "2D9219FFED9553B7D526C70232CCB2AF7E2D566BFE119B0F23ECE2439B28867D".hexToBytes
        XCTAssertEqual(nano.accounts.functions.derivePublicKey(from: privateKey), publicKey)
    }
    
    func testEncodePublicKey() {
        let publicKey = "F784127048B8744F7BA620BC16D9CEC73C2AFE54D34931E467D6A5AAB1380798".hexToBytes
        let result = "3xw64br6jg5nbxxtea7w4uewxjsw7dz7bntb89k8hoo7ocrmi3wr"
        XCTAssertEqual(nano.accounts.functions.encodePublicKey(from: publicKey), result)
    }
    
    func testCreateChecksum() {
        let publicKey = "EBC82B26FAE2FBE14BAF303492C8CF6E66391EA8F641FE74A0B0D06CEF806703".hexToBytes
        let result = "czeejhht"
        XCTAssertEqual(nano.accounts.functions.createChecksum(from: publicKey), result)
    }
    
    func testCreateAccountAndAddress() {
        let seed = "489544D50CE37B138C740189AF688067D6506423E2798B67C5091D27ABB999DA".hexToBytes
        let account = NanoAccount(
            index: 0,
            privateKey: "99E4D455A4ABE56933368C278C4A9EAB664BF0FA0C19B749BF8634206BEF3599".hexToBytes,
            publicKey: "EC08268C08F29C326880530E700EADDD2714BA77E139BE899B789F2C88471960".hexToBytes,
            type: .nano,
            encodedPublicKey: "3u1a6t81jwnw8bna1nrgg19cuqb94kx9hrbsqt6spy6z7k66g8d1",
            endodedChecksum: "zyfoz1xw"
        )
        XCTAssertEqual(try! nano.accounts.newAccount(from: seed, index: 0).privateKey, account.privateKey)
        XCTAssertEqual(try! nano.accounts.newAccount(from: seed, index: 0).publicKey, account.publicKey)
        XCTAssertEqual(try! nano.accounts.newAccount(from: seed, index: 0).publicAddress, account.publicAddress)
        XCTAssertEqual(try! nano.accounts.newAccount(from: seed, index: 0).encodedPublicKey, account.encodedPublicKey)
        XCTAssertEqual(try! nano.accounts.newAccount(from: seed, index: 0).endodedChecksum, account.endodedChecksum)
    }
    
    func testAddressValidCheck() {
        let correctAddress = "xrb_1y1craeoqjmpzzd79khsmzm65kfuapug1xyhojfp4rc85d6wm1fcgkcqx8e8"
        let correctAddress2 = "nano_1hdda1zcipzftncz155ughx5xzyunsjxygbyc6yqjqoz9emmanzc8qybmubs"
        let correctAddress3 = "ban_3aijypbpn8zqzbzi8kie6foi4549put5s7du7y8emz1n1tz91aptck7qkkcd"
        let invalidLength = "ban_3aijypbpn8zqzbzi8kie6foi449put5s7du7y8emz1n1tz91aptck7qkkcd"
        let invalidEncoding = "nano_9hdda1zcipzftncz155ughx5xzyunsjxygbyc6yqjqoz9emmanzc8qybmubs"
        let invalidPrefix = "nanoo_1qpczp3hzxzz3wdgj8fu769zsosz1xwi6ona9fy8oi1ze8ik14qn5ef7rnra"
        let invalidChecksum = "xrb_1y1craeoqjmpzzd79khsmzm65kfuapug1xyhojfp4rc85d6wm1fcgkcqx8e9"
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: correctAddress), .valid)
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: correctAddress2), .valid)
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: correctAddress3), .valid)
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: invalidLength), .invalidLength)
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: invalidEncoding), .invalidEncoding)
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: invalidPrefix), .invalidPrefix)
        XCTAssertEqual(nano.accounts.functions.checkIfAddressIsValid(address: invalidChecksum), .invalidChecksum)
    }
    
    /// # Test Block Functions
    
    func testHashStateBlock() {
        let b1 = NanoStateBlock(previous: "0000000000000000000000000000000000000000000000000000000000000000", account: "780AC2195BC676FFD653C9F99FE641C9BB45B6E077CFAC5B6161461AC9C981AA", representative: "780AC2195BC676FFD653C9F99FE641C9BB45B6E077CFAC5B6161461AC9C981AA", balance: NanoAmount(raw: "5"), link: "2961A6301E9AE41D63A21FD00C6A4A6BC346E91D5EC44DAF85B3E7C0CD8F4B33")
        let hashed1 = nano.blocks.functions.hashStateBlock(from: b1).forceUnwrap.hexString
        let expected1 = "47ADDE5A68AF36C70B6E15E0B872E79B47927A640789AE32A5118C807EA10389"
        
        let b2 = NanoStateBlock(previous: "D03326EA102A6F4DEFFA29474251C4AA0EE9D4C08489AB73AC9593ED17849C8C", account: "xrb_1xm7zsrqkwj46ebappf33hnsqbaqo5bgd7qq3zixkxq53o4w99i1pt5k4u31", representative: "nano_3ixkby46ggfiztwy7yq5jkqdqwwj69ozb5yoinb5posnnog4j9sgcey178py", balance: NanoAmount(raw: "8372937298364752"), link: "A60103F1B5DEF6569019BBE0F7C6F5BA35ADBB944D8EB3E520166928833E993A")
        let hashed2 = nano.blocks.functions.hashStateBlock(from: b2).forceUnwrap.hexString
        let expected2 = "6126EF179702EAE2A5E9B51656A5C949AA4777659D439585F1A6B539F98AB305"
        
        XCTAssertEqual(hashed1, expected1)
        XCTAssertEqual(hashed2, expected2)
    }
    
    func testSignStateBlockHash() {
        let hash1 = "BEC62BD9F7C036154619C34BDBB58E9B92FFCD516B38E7326C124803B5B3D8F1".hexToBytes
        let privKey1 = "9772ECFFF6108A7A59EAA133F927273DAEE28E4B736E7E720C8DD9E80448935C".hexToBytes
        let expected1 = "9BD47FF10A93854F6F99523095B8AD164BA15B962FB7DB2D295DF5A28D0FD9986AFF343E3B193F1DA8F55C0E498F6CF3A31053EE9EF4D0CDF35FE46482CB7105".hexToBytes
        let signed1 = nano.blocks.functions.signStateBlockHash(hash: hash1, privateKey: privKey1)
        
        let hash2 = "7167BBA21D8BB35BBA7FC88E714383D0332DB876EDBA2C118F1FFC13AB0668B3".hexToBytes
        let privKey2 = "B9D114EE0A2FD287731A636ABADB073E6613C258EE1F915DD26457CDCC4EF771".hexToBytes
        let pubKey = "B9E6446BB7E76F377CC05321968DFCB6F59ADA92FE23E2B0813C08D157AD3322".hexToBytes
        let signed2 = nano.blocks.functions.signStateBlockHash(hash: hash2, privateKey: privKey2, publicKey: pubKey)
        let expected2 = "21658E5B0EC38265575FA21BE2E036D7B0D15B766B85C71D11590BA0DDF1E02CABE4E2CC65C8B3F425F710394E0CB5548B58D288D35B029D23CA960B1632480D".hexToBytes
        
        XCTAssertEqual(signed1, expected1)
        XCTAssertEqual(signed2, expected2)
    }
}
