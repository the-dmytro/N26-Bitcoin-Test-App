//
//  Secrets.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

protocol Secrets {
    var apiKey: String { get }
}

struct CoinGeckoSecrets: Secrets {
    let resourceName = "Keys"
    let extensionName = "plist"
    let apiKeyKey = "API_KEY"

    var apiKey: String {
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

