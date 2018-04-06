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
    
    //OUTLETS
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var edLabel: UILabel!
    @IBOutlet weak var sdLabel: UILabel!
    @IBOutlet weak var protocolTextField: UITextView!
    @IBOutlet weak var eventTableView: UITableView!
    
    //VARIABLES
    var expProtocol: String!
    var startDate: String!
    var endDate: String!
    var expTitle: String!
    var autoKey: String!
    var dbRef: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _refHandle2: DatabaseHandle!
    var eventArray : [EventStruct] = []
    var pbTitle: String!
    var pbWhatUDid: String!
    var pbObsv: String!
    var sentHome: Bool = false
    var sentCollab: Bool = false
    var collabAutoKey: String!
    
    //OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDatabase()
        if sentHome {
            loadHomeCalls()
        }
        if sentCollab {
            loadCollabCalls()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let vc = segue.destination as! DetailViewController
            vc.experimentTitle = self.expTitle
            vc.tabBarController?.tabBar.isHidden = true
            vc.autoKey = self.autoKey
            vc.test = "ABCD"
            vc.sentHome = true
        }
        
        if segue.identifier == "collabToDetail" {
            let vc = segue.destination as! DetailViewController
            vc.sentCollab = true
            vc.experimentTitle = self.expTitle
            vc.collabAutoKey = self.collabAutoKey
            vc.tabBarController?.tabBar.isHidden = true
        }
        
        if segue.identifier == "resendHomeDetail" {
            if let indexPath = eventTableView.indexPathForSelectedRow {
                let vc = segue.destination as! DetailViewController
                let selectedRow = indexPath.row
                let info = eventArray[indexPath.row]
                vc.cellWhatUDid = info.whatUDid
                vc.cellObservations = info.observations
                vc.cellTitle = info.taskTitle
                vc.autoKey = self.autoKey
                vc.experimentTitle = self.expTitle
                vc.navigationItem.leftBarButtonItem?.isEnabled = false
                vc.sentHome = true
            }
        }
        
        if segue.identifier == "resendCollabDetail" {
            if let indexPath = eventTableView.indexPathForSelectedRow {
                let vc = segue.destination as! DetailViewController
                let selectedRow = indexPath.row
                let info = eventArray[indexPath.row]
                vc.cellWhatUDid = info.whatUDid
                vc.cellObservations = info.observations
                vc.cellTitle = info.taskTitle
                vc.collabAutoKey = self.collabAutoKey
                vc.experimentTitle = self.expTitle
                vc.navigationItem.leftBarButtonItem?.isEnabled = false
                vc.sentCollab = true
            }
        }
        if segue.identifier == "toInvite" {
            let vc = segue.destination as! InviteCollabViewController
            vc.baseID = self.autoKey
        }
    }
    
    //CONVENIENCE FUNCTIONS
    
    func configureUI() {
        
        setLabelAttributes(alignment: .center, textColor: .red, text: startDate, label: sdLabel)
        setLabelAttributes(alignment: .center, textColor: .red, text: endDate, label: edLabel)
        setLabelAttributes(alignment: .center, textColor: .white, text: "Start:", label: startLabel)
        setLabelAttributes(alignment: .center, textColor: .white, text: "End:", label: endLabel)

        protocolTextField.text = self.expProtocol
        protocolTextField.textAlignment = .center
        protocolTextField.delegate = self
        protocolTextField.textColor = UIColor(red:0.98, green:0.79, blue:0.30, alpha:1.0)
        
        self.tabBarController?.tabBar.isHidden = true
        
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.backgroundColor = UIColor.clear
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(segueToDetail))
        addBarButton.tintColor = UIColor(red:0.07, green:0.25, blue:0.05, alpha:1.0)
        
        
        let invBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(segueToInvite))
        invBarButton.tintColor = UIColor(red:0.07, green:0.25, blue:0.05, alpha:1.0)
        if sentCollab {
            invBarButton.isEnabled = false
        }
        
        self.navigationItem.rightBarButtonItems = [invBarButton, addBarButton]
        
        let backgroundImg = UIImageView(frame: UIScreen.main.bounds)
        if sentHome {
            backgroundImg.image = UIImage(named: "rm5")
        }
        if sentCollab {
           backgroundImg.image = UIImage(named: "portalBG")
        }
        backgroundImg.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImg, at: 0)
    }
    
    @ objc func segueToDetail() {
        if sentHome {
            performSegue(withIdentifier: "toDetailVC", sender: nil)
        }
        if sentCollab {
            performSegue(withIdentifier: "collabToDetail", sender: nil)
        }
    }
    
    @objc func segueToInvite() {
        performSegue(withIdentifier: "toInvite", sender: self)
    }
    
    func configureDatabase() {
        dbRef = Database.database().reference()
    }
    
   func loadHomeCalls() {
    
    //The first handle takes care of detailVCs without any images
    
        self.eventArray.removeAll()
        if let user = Auth.auth().currentUser {
           _refHandle = dbRef.child("Experiment").child(user.uid).child(self.autoKey).observe(.childAdded, with: {(snapshot) in

            if let snapVal = snapshot.value as? [String:AnyObject] {
                    let title = snapVal["Title"] as? String
                    if title == "" || title == nil {
                        return
                } else {
                        let event = EventStruct(dictionary: snapVal)
                        self.eventArray.insert(event!, at: 0)
                        
                        DispatchQueue.main.async {
                            self.eventTableView.reloadData()
                        }
                    }
                }
           })
            
            //This second handle takes care of detailVCs with images, since the child gets created with the image and requires the new cell to have proper info
            
            _refHandle2 = dbRef.child("Experiment").child(user.uid).child(self.autoKey).observe(.childChanged, with: {(snapshot) in
                
                if let snapVal = snapshot.value as? [String:AnyObject] {
                    let title = snapVal["Title"] as? String
                    if title == "" || title == nil {
                        return
                    }
                    let event = EventStruct(dictionary: snapVal)
                    for item in self.eventArray {
                        if event?.taskTitle == item.taskTitle {
                            let index = self.eventArray.index(where: {_ in event?.taskTitle == item.taskTitle})
                            self.eventArray.remove(at: index!)
                        }
                    }
                    self.eventArray.insert(event!, at: 0)
                    //self.eventTableView.insertRows(at: [IndexPath(row: self.eventArray.count-1, section: 0)], with: .automatic)

                    DispatchQueue.main.async {
                        self.eventTableView.reloadData()
                    }
                }
            })
        }
    }
    
    func loadCollabCalls() {
        
        //The first handle takes care of detailVCs without any images
        
        self.eventArray.removeAll()
        if let user = Auth.auth().currentUser {
            _refHandle = dbRef.child("Shared").child(collabAutoKey).observe(.childAdded, with: {(snapshot) in
                
                if let snapVal = snapshot.value as? [String:AnyObject] {
                    let title = snapVal["Title"] as? String
                    if title == "" || title == nil {
                        return
                    } else {
                        let event = EventStruct(dictionary: snapVal)
                        self.eventArray.insert(event!, at: 0)
                        
                        DispatchQueue.main.async {
                            self.eventTableView.reloadData()
                        }
                    }
                }
            })
            
            //This second handle takes care of detailVCs with images, since the child gets created with the image and requires the new cell to have proper info
            
            _refHandle2 = dbRef.child("Shared").child(collabAutoKey).observe(.childChanged, with: {(snapshot) in
                
                if let snapVal = snapshot.value as? [String:AnyObject] {
                    let title = snapVal["Title"] as? String
                    if title == "" || title == nil {
                        return
                    }
                    let event = EventStruct(dictionary: snapVal)
                    for item in self.eventArray {
                        if event?.taskTitle == item.taskTitle {
                            let index = self.eventArray.index(where: {_ in event?.taskTitle == item.taskTitle})
                            self.eventArray.remove(at: index!)
                        }
                    }
                    self.eventArray.insert(event!, at: 0)
                    //self.eventTableView.insertRows(at: [IndexPath(row: self.eventArray.count-1, section: 0)], with: .automatic)
                    
                    DispatchQueue.main.async {
                        self.eventTableView.reloadData()
                    }
                }
            })
        }
    }
    
    
    deinit {
        if let user = Auth.auth().currentUser{
            if sentHome {
             dbRef.child("Experiment").child(user.uid).child(self.autoKey).removeAllObservers()
            }
            if sentCollab {
                dbRef.child("Shared").child(self.collabAutoKey).removeAllObservers()
            }
        }
    }
    
    func setLabelAttributes(alignment: NSTextAlignment, textColor: UIColor, text: String, label: UILabel) -> UILabel {
        label.textAlignment = alignment
        label.textColor = textColor
        label.text = text
        return label
    }
}


//TEXTVIEW FUNCTIONS

extension EventViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text != expProtocol {
            if let user = Auth.auth().currentUser {
                if sentHome {
                    Database.database().reference().child("Experiment").child(user.uid).child(autoKey).updateChildValues(["Protocol":textView.text])
                }
                if sentCollab {
                    Database.database().reference().child("Shared").child(collabAutoKey).updateChildValues(["Protocol":textView.text])
                }
                DispatchQueue.main.async {
                    self.expProtocol = textView.text
                }
            }
        }
    }
}

//TABLEVIEW FUNCTIONS

extension EventViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        let info = eventArray[indexPath.row]
        cell.expLabel.text = "Task name: " + info.taskTitle
        cell.creationLabel.text = "Last edited: " + info.creationDate
        cell.backgroundColor? = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sentHome {
            performSegue(withIdentifier: "resendHomeDetail", sender: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if sentCollab {
           performSegue(withIdentifier: "resendCollabDetail", sender: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        var ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let info = eventArray[indexPath.row]
        let title = info.taskTitle
        let eventRef = ref.child("Experiment").child(userID!).child(self.autoKey)
        eventRef.child(title).removeValue()
        
        //Delete from tableView
        self.eventArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
