//
//  EventViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/7/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EventViewController : UIViewController {
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var edLabel: UILabel!
    @IBOutlet weak var sdLabel: UILabel!
    @IBOutlet weak var protocolTextField: UITextView!
    @IBOutlet weak var eventTableView: UITableView!
    
    
    var expProtocol: String!
    var startDate: String!
    var endDate: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        sdLabel.text = startDate
        sdLabel.textAlignment = .center
        edLabel.text = endDate
        edLabel.textAlignment = .center
        startLabel.textAlignment = .center
        endLabel.textAlignment = .center
        protocolTextField.text = expProtocol
        protocolTextField.textAlignment = .center
        self.tabBarController?.tabBar.isHidden = true
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(segueToDetail))
        addBarButton.tintColor = UIColor(red:0.07, green:0.25, blue:0.05, alpha:1.0)
        self.navigationItem.rightBarButtonItem = addBarButton
    }
    
    @ objc func segueToDetail() {
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
}
