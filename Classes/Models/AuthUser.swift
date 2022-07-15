//
//  MyUser.swift
//  AFNetworking
//
//  Created by apple on 1/30/22.
//
import UIKit

open class AuthUser: Codable {
    public var deviceID: String = ""

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
    }
}

public protocol UserDelegate {
    func markAsLogin(authUser: AuthUser)
    func saveAsCurrent(data: Any?)
}

open class UserBase {
    public static var current: UserDelegate!
}
