//
//  SearchEndPoint.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

enum SearchEndPoint {
    case chatGPT

    func createChatGPTRequest(messages: [ChatMessage],
                              maxTokens: Int) -> NetworkRequest {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(APIEnvironment.openAIAPIKey)"
        headers["content-type"] = "application/json"

        let body = ChatConversation(messages: messages,
                                    model: "gpt-3.5-turbo",
                                    maxTokens: maxTokens)
        var encodedBody = Data()
        let encoder = JSONEncoder()

        if let encoded = try? encoder.encode(body) {
            encodedBody = encoded
        }

        return NetworkRequest(url: APIEnvironment.openAIURL,
                              headers: headers,
                              body: encodedBody,
                              httpMethod: .post)
    }

}
