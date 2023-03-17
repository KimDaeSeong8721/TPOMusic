//
//  APIService.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    func request<T: Decodable>(type: T.Type, request: NetworkRequest) async throws -> T?
}

final class APIService: APIServiceProtocol {

    let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func request<T: Decodable>(type: T.Type, request: NetworkRequest) async throws -> T? {

        guard let encodedUrl = request.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrl) else {
            throw NetworkError.encodingError
        }
        let (data, response): (Data, URLResponse) = try await session.customDataTask(from: request.buildURLRequest(with: url))

        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.serverError }

        switch httpResponse.statusCode {
        case (200..<300):
            break
        case (300..<500):
            throw NetworkError.clientError(message: httpResponse.statusCode.description)
        default:
            throw NetworkError.serverError
        }
        let decoder = JSONDecoder()
        let itemDTO = try decoder.decode(type.self, from: data)
        return itemDTO
    }
}
