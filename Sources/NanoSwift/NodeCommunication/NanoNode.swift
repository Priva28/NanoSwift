//
//  NanoNode.swift
//  
//
//  Created by Christian Privitelli on 1/7/21.
//

import Foundation

public class NanoNode {
    public let address: String
    public let connected: Bool
    public let version: String?
    
    init(address: String) {
        self.address = address
        self.connected = false
        self.version = nil
    }
    
    private let urlSession = URLSession.shared
    
    // Async/await methods
    
    @available(watchOS 8.0, *)
    @available(tvOS 15.0, *)
    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func getAccountInfo(for account: NanoAccount) async throws -> NanoAccountInfo {
        let body = [
            "action": "account_info",
            "representative": "true",
            "account": account.publicAddress
        ]
        let data = try await rpcRequest(body: body)
        return try JSONDecoder().decode(NanoAccountInfo.self, from: data)
    }
    
    @available(watchOS 8.0, *)
    @available(tvOS 15.0, *)
    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func putAccountInfo(into account: inout NanoAccount) async throws {
        let accountInfo = try await getAccountInfo(for: account)
        account.accountInfo = accountInfo
    }
    
    @available(watchOS 8.0, *)
    @available(tvOS 15.0, *)
    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func generateWork(for account: NanoAccount, type: NanoWorkType) async throws -> String {
        guard let hash = account.accountInfo?.frontier else { throw NanoNodeError.accountInfoDoesNotExist }
        let body = [
            "action": "work_generate",
            "difficulty": type == .send ? "fffffff800000000" : type == .receive ? "fffffe0000000000" : "ffffffc000000000",
            "hash": hash
        ]
        let data = try await rpcRequest(body: body)
        let workResponse = try JSONDecoder().decode(NanoWorkGenerateResponse.self, from: data)
        return workResponse.work
    }
    
    @available(watchOS 8.0, *)
    @available(tvOS 15.0, *)
    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func getPendingBlocks(for account: NanoAccount, threshold: NanoAmount = NanoAmount(raw: "0"), includeOnlyConfirmed: Bool = true, includeActive: Bool = false) async throws -> [NanoPendingBlock] {
        let body = [
            "action": "pending",
            "account": account.publicAddress,
            "source": "true",
            "threshold": threshold.rawString,
            "include_only_confirmed": includeOnlyConfirmed ? "true" : "false",
            "include_active": includeActive ? "true" : "false"
        ]
        let data = try await rpcRequest(body: body)
        let pendingResponse = try JSONDecoder().decode(NanoPendingResponse.self, from: data)
        return pendingResponse.blocks
    }
    
    @available(watchOS 8.0, *)
    @available(tvOS 15.0, *)
    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func publish(block: NanoStateBlock, type: NanoTransactionType) async throws {
        guard let signature = block.signature?.hexString else { throw NanoNodeError.incompleteBlock }
        guard let work = block.work else { throw NanoNodeError.incompleteBlock }
        let body: [String: Any] = [
            "action": "process",
            "json_block": "true",
            "subtype": type.rawValue,
            "block": [
                "type": "state",
                "account": block.account,
                "previous": block.previous,
                "representative": block.representative,
                "balance": block.balance.rawString,
                "link": block.link,
                "signature": signature,
                "work": work
            ]
        ]
        let data = try await rpcRequest(body: body)
        print(String(data: data, encoding: .utf8) ?? "fail")
    }
    
    @available(watchOS 8.0, *)
    @available(tvOS 15.0, *)
    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func rpcRequest(body: [String: Any]) async throws -> Data {
        guard let url = URL(string: address) else { throw NanoNodeError.invalidAddress }
        var request = URLRequest(url: url)
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"
        let (data, response) = try await urlSession.upload(for: request, from: jsonData)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NanoNodeError.httpError
        }
        guard let mime = response.mimeType, mime == "application/json" else {
            throw NanoNodeError.invalidMime
        }
        return data
    }
    
    // Regular ugly completion handler methods
    
    public func getAccountInfo(for account: NanoAccount, completionHandler: @escaping (NanoAccountInfo?, Error?) -> Void) {
        let body = [
            "action": "account_info",
            "representative": "true",
            "account": account.publicAddress
        ]
        rpcRequest(body: body) { data, error in
            if error != nil {
                completionHandler(nil, error); return
            }
            guard let data = data else { completionHandler(nil, NanoNodeError.otherError); return }
            guard let accountInfo = try? JSONDecoder().decode(NanoAccountInfo.self, from: data) else { completionHandler(nil, NanoNodeError.jsonError); return }
            completionHandler(accountInfo, nil); return
        }
    }
    
    public func generateWork(for account: NanoAccount, type: NanoWorkType, completionHandler: @escaping (String?, Error?) -> Void) {
        guard let hash = account.accountInfo?.frontier else { completionHandler(nil, NanoNodeError.accountInfoDoesNotExist); return }
        let body = [
            "action": "work_generate",
            "difficulty": type == .send ? "fffffff800000000" : type == .receive ? "fffffe0000000000" : "ffffffc000000000",
            "hash": hash
        ]
        rpcRequest(body: body) { data, error in
            if error != nil {
                completionHandler(nil, error); return
            }
            guard let data = data else { completionHandler(nil, NanoNodeError.otherError); return }
            guard let workResponse = try? JSONDecoder().decode(NanoWorkGenerateResponse.self, from: data) else { completionHandler(nil, NanoNodeError.jsonError); return }
            completionHandler(workResponse.work, nil); return
        }
    }
    
    public func getPendingBlocks(for account: NanoAccount, threshold: NanoAmount = NanoAmount(raw: "0"), includeOnlyConfirmed: Bool = true, includeActive: Bool = false, completionHandler: @escaping ([NanoPendingBlock]?, Error?) -> Void) {
        let body = [
            "action": "pending",
            "account": account.publicAddress,
            "source": "true",
            "threshold": threshold.rawString,
            "include_only_confirmed": includeOnlyConfirmed ? "true" : "false",
            "include_active": includeActive ? "true" : "false"
        ]
        rpcRequest(body: body) { data, error in
            if error != nil {
                completionHandler(nil, error); return
            }
            guard let data = data else { completionHandler(nil, NanoNodeError.otherError); return }
            guard let pendingResponse = try? JSONDecoder().decode(NanoPendingResponse.self, from: data) else { completionHandler(nil, NanoNodeError.jsonError); return }
            completionHandler(pendingResponse.blocks, nil); return
        }
    }
    
    public func publish(block: NanoStateBlock, type: NanoTransactionType, completionHandler: @escaping (Error?) -> Void) {
        guard let signature = block.signature?.hexString else { completionHandler(NanoNodeError.incompleteBlock); return }
        guard let work = block.work else { completionHandler(NanoNodeError.incompleteBlock); return }
        let body: [String: Any] = [
            "action": "process",
            "json_block": "true",
            "subtype": type.rawValue,
            "block": [
                "type": "state",
                "account": block.account,
                "previous": block.previous,
                "representative": block.representative,
                "balance": block.balance.rawString,
                "link": block.link,
                "signature": signature,
                "work": work
            ]
        ]
        rpcRequest(body: body) { data, error in
            if error != nil {
                completionHandler(error); return
            }
            guard let data = data else { completionHandler(NanoNodeError.otherError); return }
            print(String(data: data, encoding: .utf8) ?? "fail")
            completionHandler(nil); return
        }
    }
    
    public func rpcRequest(body: [String: Any], completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: address) else { completionHandler(nil, NanoNodeError.invalidAddress); return }
        var request = URLRequest(url: url)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { completionHandler(nil, NanoNodeError.jsonError); return }
        request.httpMethod = "POST"
        urlSession.uploadTask(with: request, from: jsonData) { data, response, error in
            if error != nil {
                completionHandler(nil, error); return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, NanoNodeError.httpError); return
            }
            guard let mime = response?.mimeType, mime == "application/json" else {
                completionHandler(nil, NanoNodeError.invalidMime); return
            }
            completionHandler(data, nil); return
        }.resume()
    }
}

public enum NanoNodeError: Error {
    case invalidAddress
    case httpError
    case invalidMime
    case incompleteBlock
    case jsonError
    case accountInfoDoesNotExist
    case otherError
}



