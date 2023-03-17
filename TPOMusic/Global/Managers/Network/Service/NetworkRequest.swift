//
//  NetworkRequest.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/12.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct NetworkRequest {
    let url: String
    let headers: [String: String]?
    let body: Data?
    let httpMethod: HTTPMethod

    func buildURLRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers ?? [:]
        request.httpBody = body
        return request
    }
}
