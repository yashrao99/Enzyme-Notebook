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


class NewExperimentalViewController: UIViewController {
    
    //OUTLETS
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var protocolTextField: UITextView!
    @IBOutlet weak var confirmExpButton: UIButton!
    @IBOutlet var dismissKeyboardRecognizer: UITapGestureRecognizer!

    
    //VARIABLES
    
    var startDate: String!
    var endDate: String!
    var ref: DatabaseReference!
    var user: User?
    var keyboardOnScreen = false
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //IB ACTIONS
    
    @IBAction func goToCalendar(_ sender: Any) {
        performSegue(withIdentifier: "toCalendar", sender: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        var cancelAlert = UIAlertController(title: "Cancel Experiment", message: "All data will be lost", preferredStyle: .alert)
        cancelAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action:UIAlertAction!) in
            self.navigationController?.viewControllers.remove(at: 1)
            self.navigationController?.popToRootViewController(animated: true)
            }))
        cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(cancelAlert, animated: true, completion: nil)
    }
    
    @IBAction func saveExperimentPressed(_ sender: Any) {
        
        let creationDate = Date()
        let newDate = creationDate.string(with: "MMM dd, yyyy")

        //Put the experiment data per user with unique ID onto Firebase to call in tableView
        if let user = Auth.auth().currentUser {
            ref.child("Experiment").child((user.uid)).childByAutoId().setValue(["Title": "\(titleTextField.text!)", "startDate": "\(startDateTextField.text!)", "endDate" : "\(endDateTextField.text!)", "Protocol" : "\(protocolTextField.text!)", "creationDate": "\(newDate)"])
        }
        self.navigationController?.viewControllers.remove(at: 1)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //CONVENIENCE FUNCTIONS
    
    func configureUI() {
        
        //Text Fields
        startDateTextField.text = startDate ?? ""
        endDateTextField.text = endDate ?? ""
        startDateTextField.isEnabled = false
        endDateTextField.isEnabled = false
        startDateTextField.textAlignment = .center
        endDateTextField.textAlignment = .center
        
        titleTextField.delegate = self
        titleTextField.textColor = UIColor.gray
        titleTextField.text = Constants.textViewText.titleText
        
        //Nav Bar
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
        
        //UITextView
        protocolTextField.delegate = self
        protocolTextField.text = Constants.textViewText.protocolTextView
        protocolTextField.textColor = UIColor.gray
        
        //Save Experiment Button
        confirmExpButton.isHidden = true
        
        //Dismiss TextField by touch
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)
        
    }
    //Dismiss keyboard for editable textField/View
    @objc func tap(gesture: UITapGestureRecognizer) {
        titleTextField.resignFirstResponder()
        protocolTextField.resignFirstResponder()
    }
    
    //Send you back to the root nav controller
    func configureCancel() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    //Will allow to save experiment once necessary requirements are met
    func showButton() {
        if startDateTextField.text != "" && endDateTextField.text != "" && titleTextField.text != "" {
            confirmExpButton.isHidden = false
        }
    }
    
    //FIREBASE FUNCTIONS
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
}

extension NewExperimentalViewController: UITextViewDelegate {
    
    //TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.textViewText.protocolTextView {
            textView.text = ""
            textView.textColor = UIColor.black
        } else {
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.textViewText.protocolTextView
            textView.textColor = UIColor.lightGray
        }
        if !textView.text.isEmpty {
            showButton()
        }
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
 //           textView.resignFirstResponder()
  //          return false
  //      }
   //     return true
  //  }
}

extension NewExperimentalViewController: UITextFieldDelegate {
    
    //Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == Constants.textViewText.titleText {
            textField.text = ""
            textField.textColor = UIColor.black
        } else {
            textField.textColor = UIColor.black
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = Constants.textViewText.titleText
            textField.textColor = UIColor.gray
        }
        if !(textField.text?.isEmpty)! {
            showButton()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
}






