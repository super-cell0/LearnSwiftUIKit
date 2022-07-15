//
//  UserDefaultUtils.swift
//  MarkupAssistant
//
//  Created by apple on 5/31/20.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//

import UIKit

public struct UserDefaultKey {
    public static let userSearchHistory = "userSearchHistory"
    public static let user = "user"
    public static let useCount = "useCount"
    public static let deviceID = "deviceID"
    public static let AuthViewViewed = "AuthViewViewed"
}

public class UserDefaultUtils {
    // Shared Instance for the class
    public static let shared = UserDefaultUtils()

    // Don't allow instances creation of this class
    private init() {}

    public func saveObject<T: Codable>(_ object: T, _ key: String) {
        let dataEncoder = JSONEncoder()
        do {
            let data = try dataEncoder.encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            assertionFailure("Error encoding object of type \(T.self): \(error)")
        }
    }

    public func fetchObject<T>(_ key: String) -> T? where T: Decodable {
        guard let savedItem = UserDefaults.standard.object(forKey: key) as? Data else { return nil}
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: savedItem)
        } catch {
            print("Error encoding object of type \(T.self): \(error)")
        }
        return nil
    }

    public func appendStringToArray(_ key: String, _ string: String) {
        if var array: [String] = fetchObject(key) {
            array.append(string)
            saveObject(array, key)
        } else {
            let array = [string]
            saveObject(array, key)
        }
    }

    public func removeStringFromArray(_ key: String, _ string: String) {
        if var array: [String] = fetchObject(key) {
            array = array.filter { $0 != string }
            saveObject(array, key)
        }
    }

    public func removeObject(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    public func saveItem(_ item: Any, _ key: String) {
        UserDefaults.standard.set(item, forKey: key)
    }

    public func fetchItem(_ key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    public func isAuthViewViewed() -> Bool {
//        guard UserDefaultUtils.shared.fetchItem(UserDefaultKey.AuthViewViewed) != nil else {
//            return false
//        }
        return true
    }
    
    public func isAuthed() -> Bool {
        guard UserDefaultUtils.shared.fetchItem(UserDefaultKey.deviceID) != nil else {
            return false
        }
        return true
    }
    
    /*func isViewedWarningDiffSetting() -> Bool {
        guard UserDefaultUtils.shared.fetchItem(UserDefaultKey.isViewedWarningDiffSetting) != nil else {
            return false
        }
        return true
    }
    
    func setIsViewedWarningDiffSetting() {
        UserDefaultUtils.shared.saveItem(true, UserDefaultKey.isViewedWarningDiffSetting)
    }*/
}

