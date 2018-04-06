//
//  CollabViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 4/3/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CollabViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var collaborations: [ExperimentStruct] = []
    var collabKeys: [String] = []
    fileprivate var _collabHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI()
        loadCalls()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collabToEvent" {
            print("collabToEvent segue used")
            let vc = segue.destination as! EventViewController
            let row = (sender as! IndexPath).row
            let expSnap = collaborations[row]
            vc.expProtocol = expSnap.typedProtocol
            vc.startDate = expSnap.startDate
            vc.endDate = expSnap.endDate
            vc.navigationItem.title = "Events"
            vc.tabBarController?.tabBar.isHidden = true
            vc.expTitle = expSnap.title
            vc.sentCollab = true
            vc.collabAutoKey = collabKeys[row]
        }
    }
    
    func configureUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        
        let backgroundImg = UIImageView(frame: UIScreen.main.bounds)
        backgroundImg.image = UIImage(named: "Blue_Portal")
        backgroundImg.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImg, at: 0)
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationItem.title = "Collaborations"
    }
    
    func loadCalls() {
        self.collaborations.removeAll()
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        _collabHandle = ref.child("Shared").observe(.childAdded, with: { (snapshot) in
            
            if let snapVal =  snapshot.value as? [String:AnyObject] {
                if snapVal[userID!] != nil {
                    self.collabKeys.append((snapshot.key))
                    let title = snapVal["Title"] as? String
                    if title == "" || title == nil {
                        return
                    }
                    let exp = ExperimentStruct(dictionary: snapVal)
                    self.collaborations.append(exp!)
                   // self.tableView.insertRows(at: [IndexPath(row: self.collaborations.count-1, section: 0)], with: .automatic)
                        
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
}

extension CollabViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collaborations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collabCell", for: indexPath) as! CollabCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.imgView.layer.cornerRadius = cell.imgView.frame.height / 2
        cell.imgView.layer.masksToBounds = true
        cell.backgroundColor = UIColor.clear
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        cell.imgView.image = UIImage(named: "orange_portal")
        cell.imgView.contentMode = .scaleAspectFit
        
        let collabSnap = collaborations[indexPath.row]
        cell.expTitle.text = "Shared Exp: " + collabSnap.title
        cell.sharedLabel.text = "Shared On: " + collabSnap.creationDate
        
        return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "collabToEvent", sender: indexPath)
    }
}
