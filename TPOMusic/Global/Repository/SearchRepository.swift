//
//  SearchRepository.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

protocol SearchRepositoryProtocol {
    func request<T: Decodable>(type: T.Type, request: NetworkRequest) async throws -> T?

}

final class SearchRepository: SearchRepositoryProtocol {
    // MARK: - Properties
    private let apiService: APIServiceProtocol?

    // MARK: - Init
    init(_ apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    // MARK: - Func
    func request<T: Decodable>(type: T.Type, request: NetworkRequest) async throws -> T? {
        return try await apiService?.request(type: type, request: request)
    }
}

