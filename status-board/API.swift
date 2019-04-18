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
        case stops(parameters: [String: Any]?)
        case arrivals(parameters: [String: Any]?)
        case vehicles(parameters: [String: Any]?)
        
        static let baseParameters: [String: Any] = [
            "appID": API.manager.token,
            "json": "true"
        ]
        
        func url() -> URL {
            var url = API.manager.base
            switch self {
            case .stops:
                url += "V1/stops"
            case .arrivals:
                url += "V1/arrivals"
            case .vehicles:
                url += "v2/vehicles"
            }
            
            return URL(string: url)!
        }
        
        func parameters() -> [String: Any] {
            var allParameters = Endpoint.baseParameters
            var overrides: [String: Any]? = nil
            switch self {
            case .stops(let parameters):
                overrides = parameters
                allParameters["feet"] = 2640 as AnyObject?
                allParameters["ll"] = "\(Location.headquartersLocation.latitude),\(Location.headquartersLocation.longitude)" as AnyObject?
                allParameters["showRoutes"] = "true" as AnyObject?
            case .arrivals(let parameters):
                overrides = parameters
                allParameters["streetcar"] = "true" as AnyObject?
            case .vehicles(let parameters):
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
    fileprivate let token = AppDelegate.keys.trimetAPIKey()!
    static let maxKMLEndpoint = "https://developer.trimet.org/gis/data/tm_rail_lines.kml"
    
    func request(_ endpoint: API.Endpoint, completionHandler:@escaping (Result<Any>)->()) {
        Alamofire.request(endpoint.url(), parameters: endpoint.parameters()).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    completionHandler(Result.success(value))
                }
            case .failure(let error):
                completionHandler(Result.failure(error))
            }
        }
    }
}
