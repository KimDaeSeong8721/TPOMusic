//
//  ChatGPTResult.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

public struct ChatGPTResult: Codable {
    public let object: String
    public let model: String?
    public let choices: [MessageResult]
}

public struct MessageResult: Codable {
    public let message: ChatMessage
}
