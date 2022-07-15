//
//  NetworkProvider.swift
//  McD MOP
//
//  Created by Kush Sharma on 17/08/17.
//  Copyright © 2017 Plexure. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class NetworkProvider {
    
    static let shared = NetworkProvider()
    var alamofireManager: Alamofire.SessionManager?
    // Don't allow instances creation of this class
    private init() {
        configureAlamofire()
    }
    
    open func configureAlamofire() {
        // Set different policies for each host
        let ServerTrustPolicies: [String : ServerTrustPolicy] = [:]

        alamofireManager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: ServerTrustPolicies))
        alamofireManager?.retrier = RequestRetryHandler()
    }

        func sendRequest(_ baseRequest: BaseRequest, _ completionHandler: CompletionHandler?) -> Void {
            //Send the request
            self.alamofireManager?.request(baseRequest).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        print(json)
                        guard let completionHandler = completionHandler else { return }
                        guard let res = response.data else { return }
                        guard let jsonResponse = try? JSON(data: res) else { return }
                        if jsonResponse["success"].error != .notExist {
                            if jsonResponse["success"].boolValue {
                                let data = try? jsonResponse["data"].rawData()
                                let allData = try? jsonResponse.rawData()
                                let responseData = baseRequest.parseNetworkResponse(data ?? allData ?? Data())
                                completionHandler(responseData, nil)
                            } else {
                                completionHandler(nil, MyError(message: jsonResponse["message"].stringValue))
                            }
                        } else if jsonResponse["error"].error == .notExist {
                            let data = try? jsonResponse["showapi_res_body"].rawData()
                            let allData = try? jsonResponse.rawData()
                            let responseData = baseRequest.parseNetworkResponse(data ?? allData ?? Data())
                            completionHandler(responseData, nil)
                        } else {
                            completionHandler(nil, MyError(message: jsonResponse["message"].stringValue))
                        }
                    }
                case .failure:
                    if response.error.debugDescription.contains("\(NSURLErrorTimedOut)") || response.error.debugDescription.contains("\(NSURLErrorNotConnectedToInternet)") {
                        DispatchQueue.main.async {
                            H.info(H.t("no_network.title"))
                        }
                    }
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, MyError(message: response.error.debugDescription))
                    break
                }
            }
        }
    
}

open class RequestRetryHandler: RequestRetrier {
    
    let maxRetries: Int = 3
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 429,
            request.retryCount < maxRetries {
            /**
             * Add jitter to retry delay to stop multiple clients
             * from retrying at the same time
             */
            let jitter = Double.random(in: 0...1)
            completion(true, 2.0 + jitter) // retry after interval between 2 - 3 seconds
        } else {
            completion(false, 0.0) // don't retry
        }
    }
}
