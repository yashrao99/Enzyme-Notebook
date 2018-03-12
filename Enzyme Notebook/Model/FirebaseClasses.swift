//
//  FirebaseClasses.swift
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
        
        self.typedProtocol = dictionary["Protocol"] as! String
        self.title = dictionary["Title"] as! String
        self.creationDate = dictionary["creationDate"] as! String
        self.endDate = dictionary["endDate"] as! String
        self.startDate = dictionary["startDate"] as! String
    }
}

struct EventStruct {
    
}
