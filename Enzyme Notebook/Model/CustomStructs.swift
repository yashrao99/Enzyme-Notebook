//
//  CustomStructs.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/7/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct ExperimentStruct {
    
    var typedProtocol = ""
    var title = ""
    var creationDate = ""
    var endDate = ""
    var startDate = ""
    
    init?(dictionary: [String:AnyObject]) {
        
        self.typedProtocol = dictionary["Protocol"] as? String ?? ""
        self.title = dictionary["Title"] as? String ?? ""
        self.creationDate = dictionary["creationDate"] as? String ?? ""
        self.endDate = dictionary["endDate"] as? String ?? ""
        self.startDate = dictionary["startDate"] as? String ?? ""
    }
}

struct EventStruct {
    
    var taskTitle = ""
    var whatUDid = ""
    var observations = ""
    var creationDate = ""
    
    init?(dictionary: [String:AnyObject]) {
        
        self.whatUDid = dictionary["Experimental"] as? String ?? ""
        self.taskTitle = dictionary["Title"] as? String ?? ""
        self.observations = dictionary["Observations"] as? String ?? ""
        self.creationDate = dictionary["creationDate"] as? String ?? ""
    }
}

struct GoogleSearchStruct {
    
    var urlLink = ""
    var htmlSnippet = ""
    var fixedHTMLText = ""
    var title = ""
    
    init?(dictionary: [String:AnyObject]) {
        
        self.urlLink = dictionary["link"] as? String ?? ""
        self.htmlSnippet = dictionary["snippet"] as? String ?? ""
        self.fixedHTMLText = GoogleSearchStruct.removeHTMLtags(htmlSnippet)
        self.title = dictionary["title"] as? String ?? ""
    }
    
    static func removeHTMLtags(_ htmlSnippet: String) -> String {
       let htmlRemoved = htmlSnippet.replacingOccurrences(of: "<[^>]+>", with: "", options:String.CompareOptions.regularExpression , range: nil)
        
        return htmlRemoved
    }
}
