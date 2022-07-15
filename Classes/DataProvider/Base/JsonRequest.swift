//
//  JsonRequest.swift
//  McD MOP
//
//  Created by Kush Sharma on 17/08/17.
//  Copyright © 2017 Plexure. All rights reserved.
//

import Foundation

open class JsonRequest<T: Codable>: BaseRequest {
    open override func parseNetworkResponse(_ response: Any) -> Any? {
        guard let res = response as? Data else { return nil }
        return DecodingUtils.decodeData(res, to: T.self)
    }
}

open class DecodingUtils {
    static func decodeData<T: Decodable>(_ data: Data, to type: T.Type) -> T? {
        let decoder = JSONDecoder()
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(df)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decoding \(T.self): \(error)")
        }
        return nil
    }
}
