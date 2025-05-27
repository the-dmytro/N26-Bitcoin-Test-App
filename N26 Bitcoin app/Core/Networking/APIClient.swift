//
//  APIClient.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
}

protocol APIClient {
    var requestBuilder: RequestBuilder { get }
    func send<T: Decodable>(_ endpoint: Endpoint) async -> Result<T, APIError>
}

final class URLSessionAPIClient: APIClient {
    let requestBuilder: RequestBuilder

    init(requestBuilder: RequestBuilder) {
        self.requestBuilder = requestBuilder
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async -> Result<T, APIError> {
        let request: URLRequest
        do {
            request = try requestBuilder.makeRequest()
        } catch {
            return .failure(.networkError(error))
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            return .failure(.networkError(error))
        }

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            return .failure(.invalidResponse)
        }

        do {
            let value = try JSONDecoder().decode(T.self, from: data)
            return .success(value)
        } catch {
            return .failure(.decodingError(error))
        }
    }
}