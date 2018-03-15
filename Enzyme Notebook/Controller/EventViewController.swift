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
    var autoKeyForPics: String!
    var dbRef: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    var eventArray : [EventStruct] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDatabase()
        loadCalls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    func configureUI() {
        setLabelAttributes(alignment: .center, textColor: .red, text: startDate, label: sdLabel)
        setLabelAttributes(alignment: .center, textColor: .red, text: endDate, label: edLabel)
        setLabelAttributes(alignment: .center, textColor: .white, text: "Start Date:", label: startLabel)
        setLabelAttributes(alignment: .center, textColor: .white, text: "End Date:", label: endLabel)

        protocolTextField.text = expProtocol
        protocolTextField.textAlignment = .center
        protocolTextField.delegate = self
        protocolTextField.textColor = UIColor(red:0.98, green:0.79, blue:0.30, alpha:1.0)
        
        self.tabBarController?.tabBar.isHidden = true
        
        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(segueToDetail))
        addBarButton.tintColor = UIColor(red:0.07, green:0.25, blue:0.05, alpha:1.0)
        self.navigationItem.rightBarButtonItem = addBarButton
        
    }
    
    @ objc func segueToDetail() {
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    func configureDatabase() {
        dbRef = Database.database().reference()
    }
    
   func loadCalls() {
        self.eventArray.removeAll()
        if let user = Auth.auth().currentUser {
           _refHandle = dbRef.child("Experiment").child(user.uid).child(self.autoKey).observe(.childAdded, with: {(snapshot) in

            if let snapVal = snapshot.value as? [String:AnyObject] {
                let event = EventStruct(dictionary: snapVal)
                self.eventArray.append(event!)
                print(self.eventArray)

                DispatchQueue.main.async {
                    self.eventTableView.reloadData()
                }
            }
           })

      }
   }

    deinit {
        if let user = Auth.auth().currentUser{
            dbRef.child("Experiment").child(user.uid).child(self.autoKey).removeAllObservers()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let vc = segue.destination as! DetailViewController
            vc.experimentTitle = self.expTitle
            vc.autoKey = self.autoKey
            vc.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func setLabelAttributes(alignment: NSTextAlignment, textColor: UIColor, text: String, label: UILabel) -> UILabel {
        label.textAlignment = alignment
        label.textColor = textColor
        label.text = text
        return label
    }
}

extension EventViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text != expProtocol {
            if let user = Auth.auth().currentUser {
                Database.database().reference().child("Experiment").child(user.uid).child(autoKey).updateChildValues(["Protocol":textView.text])
            }
        }
    }
}

extension EventViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
            let info = eventArray[indexPath.row]
            cell.textLabel?.text = info.taskTitle
        
        
        return cell
    }
}
