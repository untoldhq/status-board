//
//  API.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import Alamofire

struct API {
    static let manager = API()
    
    enum Endpoint {
        case Stops(parameters: [String: AnyObject]?)
        case Arrivals(parameters: [String: AnyObject]?)
        case Vehicles(parameters: [String: AnyObject]?)
        
        static let baseParameters: [String: AnyObject] = [
            "appID": API.manager.token,
            "json": "true"
        ]
        
        func url() -> NSURL {
            var url = API.manager.base
            switch self {
            case .Stops:
                url += "V1/stops"
            case .Arrivals:
                url += "V1/arrivals"
            case .Vehicles:
                url += "v2/vehicles"
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
                allParameters["ll"] = "\(Location.manager.location.latitude),\(Location.manager.location.longitude)"
                allParameters["showRoutes"] = "true"
            case .Arrivals(let parameters):
                overrides = parameters
                allParameters["streetcar"] = "true"
            case .Vehicles(let parameters):
                overrides = parameters
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
    
    
    func request(endpoint: API.Endpoint, completionHandler:(Result<AnyObject, NSError>)->()) {
        Alamofire.request(.GET, endpoint.url(), parameters: endpoint.parameters()).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    completionHandler(Result.Success(value))
                }
            case .Failure(let error):
                completionHandler(Result.Failure(error))
            }
        }
    }
}
