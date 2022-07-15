//
//  DataProvider.swift
//  McD MOP
//
//  Created by Kush Sharma on 18/08/17.
//  Copyright © 2017 Plexure. All rights reserved.
//

import Foundation

open class DataManager {
    public static var shared = DataManager()
    
    public init() {
    }
    
    open func getAccessToken() -> String {
        return ""
    }
    
    open func userUpdate(params: [String: String], _ completionHandler: CompletionHandler?) {
        fatalError("Need implement userUpdate")
    }
    
    open func userAuth(token: String, _ completionHandler: CompletionHandler?) {
        fatalError("Need implement userAuth")
    }
    
    // MARK: - Private methods
    open func processRequest(_ request: BaseRequest,_ completionHandler: CompletionHandler?) -> Void {
        self.executeRequest(request, completionHandler)
    }

    open func executeRequest(_ request: BaseRequest,_ completionHandler: CompletionHandler?) -> Void {
        if request.needsAccessToken() {
            /*
             * Set the Access Token to the request header.
             */
            request.setAccessToken(token: getAccessToken())
        }
        
        NetworkProvider.shared.sendRequest(request) {(_ data: Any, _ error: Error?) in
            completionHandler?(data, error)
        }
    }
}
