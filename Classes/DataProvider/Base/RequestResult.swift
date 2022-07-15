//
//  RequestResult.swift
//  MarkupAssistant
//
//  Created by apple on 5/5/20.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//

import UIKit

class RequestResult: Codable {
    public var success: Bool = false
    public var message: String = ""

    private enum CodingKeys: String, CodingKey {
        case success
        case message
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = (try? container.decode(.success) as Bool) ?? false
        self.message = (try? container.decode(.message) as String) ?? ""
    }
}
