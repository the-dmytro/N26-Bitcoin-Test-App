//
//  NetworkingMocks.swift
//  N26 Bitcoin appTests
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation
@testable import N26_Bitcoin_app

// MARK: - Mock Response

struct MockResponse: Codable {
    let message: String
}

// MARK: - Mock Endpoint

class MockEndpoint: Endpoint {
    var shouldFailOnMakeRequest = false
    
    var baseURL: URL {
        URL(string: .testMockAPIURL)!
    }
    
    var path: String {
        .testMockPath
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: [String: String] {
        [.headerAccept: .contentTypeJSON]
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    func makeRequest() throws -> URLRequest {
        if shouldFailOnMakeRequest == true {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
} 