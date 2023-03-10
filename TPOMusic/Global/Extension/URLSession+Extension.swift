//
//  URLSession+Extension.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/28.
//

import Foundation

protocol URLSessionProtocol {
    func customDataTask(from urlRequest: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    /// custom data
    func customDataTask(from urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

}

