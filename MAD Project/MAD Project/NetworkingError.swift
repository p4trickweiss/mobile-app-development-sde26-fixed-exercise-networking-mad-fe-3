//
//  NetworkingError.swift
//  MAD Project
//

import Foundation

enum NetworkingError: Error {
    case serializationFailed(String)
    case invalidEmail
    case unknownEmail
    case wrongPassword
    case offline(String)
    case unexpectedFormat
    case httpError(Int)
    case unexpected(String)
}

struct ResponseError: Codable {
    struct Body: Codable {
        let code: Int
        let message: String
        let errors: [Detail]
    }

    struct Detail: Codable {
        let message: String
        let domain: String
        let reason: String
    }

    let error: Body
}
