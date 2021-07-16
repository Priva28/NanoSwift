//
//  NanoAccountInfo.swift
//  
//
//  Created by Christian Privitelli on 13/6/21.
//

public struct NanoAccountInfo: Codable {
    public let frontier: String
    public let open_block: String
    public let representative_block: String
    public let balance: String
    public let modified_timestamp: String
    public let block_count: String
    public let account_version: String
    public let confirmation_height: String
    public let confirmation_height_frontier: String
    public let representative: String
}
