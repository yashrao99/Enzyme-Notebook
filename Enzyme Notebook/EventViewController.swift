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
    var expTitle: String!
    var autoKey: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        setLabelAttributes(alignment: .center, textColor: .red, text: startDate, label: sdLabel)
        setLabelAttributes(alignment: .center, textColor: .red, text: endDate, label: edLabel)
        setLabelAttributes(alignment: .center, textColor: .white, text: "Start Date:", label: startLabel)
        setLabelAttributes(alignment: .center, textColor: .white, text: "End Date:", label: endLabel)

        protocolTextField.text = expProtocol
        protocolTextField.textAlignment = .center
        protocolTextField.textColor = UIColor(red:0.98, green:0.79, blue:0.30, alpha:1.0)
        
        self.tabBarController?.tabBar.isHidden = true
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(segueToDetail))
        addBarButton.tintColor = UIColor(red:0.07, green:0.25, blue:0.05, alpha:1.0)
        self.navigationItem.rightBarButtonItem = addBarButton
    }
    
    @ objc func segueToDetail() {
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let vc = segue.destination as! DetailViewController
            vc.experimentTitle = self.expTitle
            vc.autoKey = self.autoKey
        }
    }
    
    
    func setLabelAttributes(alignment: NSTextAlignment, textColor: UIColor, text: String, label: UILabel) -> UILabel {
        label.textAlignment = alignment
        label.textColor = textColor
        label.text = text
        return label
    }
    
}
