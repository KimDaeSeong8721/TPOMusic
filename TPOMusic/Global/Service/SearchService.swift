//
//  SearchService.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

protocol SearchServiceProtocol {
    func fetchChatGPT(messages: [ChatMessage], maxTokens: Int) async throws -> ChatGPTResult?
}

final class SearchService: SearchServiceProtocol {

    // MARK: - Properties
    private let searchRepository: SearchRepositoryProtocol

    // MARK: - Init
    init(_ searchRepository: SearchRepositoryProtocol) {
        self.searchRepository = searchRepository
    }

    // MARK: - Func
    func fetchChatGPT(messages: [ChatMessage], maxTokens: Int) async throws -> ChatGPTResult? {
        let networkRequest = SearchEndPoint.chatGPT.createChatGPTRequest(messages: messages, maxTokens: maxTokens)
        return try await searchRepository.request(type: ChatGPTResult.self, request: networkRequest)
    }
}
