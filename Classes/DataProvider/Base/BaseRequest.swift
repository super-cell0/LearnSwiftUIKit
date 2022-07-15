//
//  BaseRequest.swift
//  McD MOP
//
//  Created by Kush Sharma on 16/08/17.
//  Copyright © 2017 Plexure. All rights reserved.
//

import Foundation
import Alamofire


/**
 * Completion handler for the asynchronous methods.
 *
 * @param data
 *      Data returned from service call if successful.
 * @param error
 *      Error object returned from service call if fails.
 */
public typealias CompletionHandler = (_ data: Any?, _ error: Error?) -> Void

open class BaseRequest : URLRequestConvertible {
    
    public var urlRequest: URLRequest
    
    public init(method: HTTPMethod, urlPath: String) {
        // Init request with the URL path
        self.urlRequest = URLRequest(url: URL(string: urlPath)!)
        
        // Set the request timeout interval to 30 seconds
        self.urlRequest.timeoutInterval = 30

        // Set the default headers for the request
        setDefaultHeaders()

        self.urlRequest.httpMethod = method.rawValue
    }
    
    public func asURLRequest() throws -> URLRequest {
        return self.urlRequest
    }
    
    /**
     * Sets the parameters received to the request's query.
     *
     * @param queryParams
     * 		Params to add to the request's query.
     */
    public func setQueryParams(_ queryParams: Dictionary<String, String>) {
        var params = [String]()
        
        // Add all params in the dictionary received as query params in the query string
        for (key, value) in queryParams {
            let param = String(format: "%@=%@", key, value)
            params.append(param.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        }
        
        var urlComponents = URLComponents(url: self.urlRequest.url!, resolvingAgainstBaseURL: true)
        urlComponents!.percentEncodedQuery = params.joined(separator: "&")
        
        self.urlRequest.url = urlComponents!.url
    }
    
    /**
     * Sets the parameters received to the request's body.
     *
     * @param bodyDict
     * 		Params to add to the request's body.
     */
    public func setBody(_ bodyDict: Dictionary<String, Any>) {
        // Setting the `Content-Type` of the request
        self.urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Sending 0 as the "writting options" param because that's the same value sent by JSONRequestSerializer.
        do {
            try self.urlRequest.httpBody = JSONSerialization.data(withJSONObject: bodyDict, options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch {
            print("Failed to serialize JSON object with error: \(error)")
        }
    }
    
    /**
     * Sets the parameters received to the request's body.
     *
     * @param body
     *         Params to add to the request's body, conforming to Encodable.
     */
    public func setBody<T: Encodable>(_ body: T) {
        // Setting the `Content-Type` of the request
        self.urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(body)
        
        self.urlRequest.httpBody = data
    }
    
    /**
     * Process orginal response data (e.g., convert JSON to objects).
     *
     * @param response
     *		Original JSON data returned from the backend.
     */
    public func parseNetworkResponse(_ response: Any) -> Any? {
        return response
    }
    
    /**
     * Returns `true` if the request needs an access token to be accepted by the platform, or `false` if it
     * doesn't.
     * Some requests can be send without access token (e.g., Authorize), while others need
     * it for the platform to accept them as valid.
     *
     * @return `true` if the access token is needed for this request, or `false` otherwise.
     */
    open func needsAccessToken() -> Bool {
        // Throw exception if this method was not overriden by the child class
        preconditionFailure("\(self) does not overwrite the needsAccessToken() method")
    }
    
    /**
     * Adds the `Authorization` header to the request with the bearer token.
     */
    public func setAccessToken(token: String) {
        self.urlRequest.setValue(token, forHTTPHeaderField: "authorization")
    }
    
    public func needEncryption() -> Bool {
        return true
    }
    
    private func setDefaultHeaders() {
    }
}
