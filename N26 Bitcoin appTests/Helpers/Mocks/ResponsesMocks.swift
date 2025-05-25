//
//  ResponsesMocks.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 25/5/25.
//

import Foundation

enum ResponsesMocks {
    static let simplePrice = """
{ "bitcoin": { "usd": 100.5, "eur": 90.75 } }
"""

    static let marketChart = """
{
  "prices": [[1,2]],
  "market_caps": [[3,4]],
  "total_volumes": [[5,6]]
}
"""

    static let coinHistory = """
{
  "market_data": {
    "current_price": { "usd": 100.0, "eur": 90.0 }
  }
}
"""
} 