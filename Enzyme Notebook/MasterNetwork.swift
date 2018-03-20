//
//  MasterNetwork.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/19/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit

class MasterNetwork : NSObject {
    
    
    func buildURL(_ parameters: [String:String]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.GoogleSearchAPI.scheme
        components.host = Constants.GoogleSearchAPI.host
        components.path = Constants.GoogleSearchAPI.path
        components.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    func googleSearch(_ url: URL, completionHandlerForSearch: @escaping (_ success: Bool,_ results: [GoogleSearchStruct]?, _ error: String?) -> Void) {
        
        var request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {data, response, error in
            
            func displayError(_ error: String) {
                print(error)
            }
            
            guard (error == nil) else {
                displayError("There is an error with network request - \(error)")
                completionHandlerForSearch(false, nil, error as! String)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                completionHandlerForSearch(false, nil, error as! String)
                return
            }
            
            guard let data = data else {
                displayError("There was no data returned by the request!")
                completionHandlerForSearch(false, nil, error as! String)
                return
            }
            
            var parsedResult: [String:AnyObject]
            var structResults: [GoogleSearchStruct] = []
            structResults.removeAll()
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Cannot display the data as JSON")
                return
            }
            
            if let arrayOfDicts = parsedResult["items"] as? [[String:AnyObject]] {
                for dict in arrayOfDicts {
                   let searchResult =  GoogleSearchStruct(dictionary: dict)
                    structResults.append(searchResult!)
                    completionHandlerForSearch(true, structResults, nil)
                }
            }
        }
        task.resume()
    }
    
    class func sharedInstance() -> MasterNetwork {
        struct Singleton {
            static var sharedInstance = MasterNetwork()
        }
        return Singleton.sharedInstance
    }
}
