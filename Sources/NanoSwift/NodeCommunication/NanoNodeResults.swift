//
//  NanoNodeResults.swift
//  
//
//  Created by Christian Privitelli on 6/7/21.
//

import Foundation

// MARK: Work Generation

public struct NanoWorkGenerateResponse: Codable {
    let work: String
    let difficulty: String
    let multiplier: String
    let hash: String
}

// MARK: Pending Command

public struct NanoPendingBlock {
    public let hash: String
    public let amount: NanoAmount
    public let source: String
}

struct NanoPendingBlockDecoder: Decodable {
    let amount: String
    let source: String
}

public struct NanoPendingResponse: Decodable {
    private let jsonBlocks: [String: NanoPendingBlockDecoder]
    
    public var blocks: [NanoPendingBlock] {
        return jsonBlocks.map { hash, blockData in
            NanoPendingBlock(hash: hash, amount: NanoAmount(raw: blockData.amount), source: blockData.source)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case jsonBlocks = "blocks"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let blocks = try? container.decode([String: NanoPendingBlockDecoder].self, forKey: .jsonBlocks)
        jsonBlocks = blocks ?? [:]
    }
}
