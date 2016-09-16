//
//  API.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct API {
    static let manager = API()
    
    enum Endpoint {
        case Stops(parameters: [String: AnyObject]?)
        
        static let baseParameters: [String: AnyObject] = [
            "appID": API.manager.token,
            "json": "true"
        ]
        
        func url() -> NSURL {
            var url = API.manager.base
            switch self {
            case .Stops:
                url += "V1/stops"
            }
            return NSURL(string: url)!
        }
        
        func parameters() -> [String: AnyObject] {
            var allParameters = Endpoint.baseParameters
            var overrides: [String: AnyObject]? = nil
            switch self {
            case .Stops(let parameters):
                overrides = parameters
                allParameters["feet"] = 2640
                allParameters["ll"] = "\(Data.manager.location.latitude),\(Data.manager.location.longitude)"
                allParameters["showRoutes"] = "true"
            }
            
            //if a parameters dictionary is present, override/set all key/value pairs
            guard let parameters = overrides else {
                return allParameters
            }
            for (key, value) in parameters {
                allParameters[key] = value
            }
            return allParameters
        }
    }
    
    let base = "https://developer.trimet.org/ws/"
    private let token = AppDelegate.keys.trimetAPIKey()
    
    
    func request(endpoint: API.Endpoint, completionHandler:(Result<JSON, NSError>)->()) {
        Alamofire.request(.GET, endpoint.url(), parameters: endpoint.parameters()).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    completionHandler(Result.Success(json))
                }
            case .Failure(let error):
                completionHandler(Result.Failure(error))
            }
        }
    }
}
