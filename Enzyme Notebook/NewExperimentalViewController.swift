//
//  NewExperimentalViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/5/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuthUI


class NewExperimentalViewController: UIViewController, UITextViewDelegate {
    
    //OUTLETS
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var protocolTextField: UITextView!
    @IBOutlet weak var confirmExpButton: UIButton!
    
    //VARIABLES
    
    var startDate: String!
    var endDate: String!
    var genericText: String! = "List out your general protocol.\n You will fill in the details later!\n Example:\n Grow E.coli cultures for 24 hours at 37° C.\n Add IPTG for induction and reduce temperature to 18°C for 12 hours.\n Spin down cells at 3000x rpm for 30 minutes.\n Add 30 mL of Lysis buffer and sonicate at 30% amplitude 3 times.\n Ultracentrifuge at 33,000 rpm and pool supernatant.\n Inject supernatant into FPLC with Ni-NTA column at 2 mL/min.\n Elute with HisB buffer with 500 mm imidazole.\n Analyze elute using gel electrophoresis (SDS-Page)."
    var ref: DatabaseReference!
    var user: User?
    
    //OVERRIDE FUNCTIONS

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCancel()
        configureDatabase()
        }
    
    //IB ACTIONS
    
    @IBAction func goToCalendar(_ sender: Any) {
        performSegue(withIdentifier: "toCalendar", sender: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        var cancelAlert = UIAlertController(title: "Cancel Experiment", message: "All data will be lost", preferredStyle: .alert)
        cancelAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action:UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)
            }))
        cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(cancelAlert, animated: true, completion: nil)
    }
    
    @IBAction func saveExperimentPressed(_ sender: Any) {
        ref.child("users").child((user?.uid)!).child("Experiment").setValue(["Title": "\(titleTextField.text!)", "startDate": "\(startDateTextField.text!)", "endDate" : "\(endDateTextField.text!)", "Protocol" : "\(protocolTextField.text!)"])
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //CONVENIENCE FUNCTIONS
    
    func configureUI() {
        
        //Text Fields
        startDateTextField.text = startDate ?? ""
        endDateTextField.text = endDate ?? ""
        startDateTextField.isEnabled = false
        endDateTextField.isEnabled = false
        
        //Nav Bar
        self.navigationItem.hidesBackButton = true
        
        //UITextView
        protocolTextField.delegate = self
        protocolTextField.text = genericText
        protocolTextField.textColor = UIColor.gray
        protocolTextField.alpha = 0.5
        
        //Save Experiment Button
        confirmExpButton.isHidden = true
        
    }
    
    func configureCancel() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func showButton() {
        if startDateTextField.text != "" && endDateTextField.text != "" && titleTextField.text != "" {
            confirmExpButton.isHidden = false
        }
    }
    
    
    //FIREBASE FUNCTIONS
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    
    //TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = genericText
            textView.textColor = UIColor.lightGray
        }
        if !textView.text.isEmpty {
            showButton()
        }
    }
    
}
