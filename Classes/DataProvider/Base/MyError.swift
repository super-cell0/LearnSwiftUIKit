//
//  MyError.swift
//  CosmeticManager
//
//  Created by 童迅 on 2021/6/9.
//

import UIKit

public class MyError: Codable, Error {
    public var message: String?

    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(message: String) {
        self.message = message
    }
}
