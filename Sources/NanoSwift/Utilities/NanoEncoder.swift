//
//  NanoEncoder.swift
//  
//
//  Created by Christian Privitelli on 6/3/21.
//

class NanoEncoder {
    
    init() {
        populateTables()
    }
    
    var characterTable: [String: String] = [:]
    var binaryTable: [String: String] = [:]
    
    private func populateTables() {
        let possibleCharacters = "13456789abcdefghijkmnopqrstuwxyz".map { String($0) }
        
        for char in 0..<possibleCharacters.count {
            let binaryNum = String(char, radix: 2)
            let binary = String(repeating: "0", count: 5-binaryNum.count)+binaryNum
            characterTable[binary] = possibleCharacters[char]
            binaryTable[possibleCharacters[char]] = binary
        }
    }
    
    func base32NanoEncode(message: Bytes, binaryLength: Int) -> String? {
        let binary = message.binaryString(length: binaryLength)
        
        var result = ""
        
        for i in stride(from: 0, to: binary.count, by: 5) {
            guard let character = characterTable[String(binary.dropFirst(i).prefix(5))] else { return nil }
            result += character
        }
        
        return result
    }
    
    func base32NanoDecode(message: String) -> String? {
        var resultUnformatted = ""
        
        for i in 0..<message.count {
            guard let binary = binaryTable[String(message[i])] else { return nil }
            resultUnformatted += binary
        }
        
        let result = String(repeating: "0", count: 264-resultUnformatted.count) + resultUnformatted
        
        return result
    }
}
