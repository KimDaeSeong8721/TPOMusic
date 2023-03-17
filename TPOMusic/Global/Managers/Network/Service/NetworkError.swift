//
//  NetworkError.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/12.
//

import Foundation

enum NetworkError: Error {
    case encodingError
    case clientError(message: String?)
    case serverError
}
