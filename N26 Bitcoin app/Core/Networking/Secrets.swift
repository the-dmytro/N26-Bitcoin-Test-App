//
//  Secrets.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

struct Secrets {
    static let resourceName = "Keys"
    static let extensionName = "plist"
    static let apiKeyKey = "API_KEY"

    static var apiKey: String {
        guard
            let url = Bundle.main.url(forResource: resourceName, withExtension: extensionName),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any],
            let key = plist[apiKeyKey] as? String,
            key.isEmpty == false
        else {
            fatalError("No API key found in \(resourceName).\(extensionName)")
        }
        return key
    }
}

