//
//  NewExperimentalViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/5/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit


class NewExperimentalViewController: UIViewController {
    
    //OUTLETS
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    //VARIABLES
    
    var startDate: String!
    var endDate: String!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        }
    
    @IBAction func goToCalendar(_ sender: Any) {
        performSegue(withIdentifier: "toCalendar", sender: nil)
    }
    
    func configureUI() {
        startDateTextField.text = startDate ?? ""
        endDateTextField.text = endDate ?? ""
    }
    
    
}
