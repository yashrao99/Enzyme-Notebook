//
//  InviteCollabViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/28/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class InviteCollabViewController: UIViewController {
    
    var listOfNames:[String] = []
    var listEmails:[String] = []
    var searchActive: Bool = false
    var users: [UsersStruct] = []
    var uid : [String] = []
    var selectedRows: [UsersStruct] = []

    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var confirmButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
    }
    
    func configureUI() {
        self.tabBarController?.tabBar.isHidden = true
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.allowsMultipleSelection = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func loadUsers() {
        
        let userRef = Database.database().reference().child("users")
        userRef.observe(.childAdded, with: {(snapshot) in
            
            if let id = snapshot.key as? String {
                self.uid.append(id)
            }
            
            if let snapVal = snapshot.value as? [String:AnyObject] {
                let person = UsersStruct(dictionary: snapVal)
                self.users.append(person!)
                
                DispatchQueue.main.async {
                    self.resultTableView.reloadData()
                }
            }
        })
    }
    
    @IBAction func buttonPressed( _ sender: Any?) {
        
        let ref = Database.database().reference()
        if let user = Auth.auth().currentUser {
            var pathToExp = ref.child("Experiment").child(user.uid).child(self.baseID)
            pathToExp.observe(.value, with: { (snapshot) in
                if let data = snapshot.value as? [String:AnyObject] {
                    let selectedRows = self.resultTableView.indexPathsForSelectedRows
                    let collabPath = ref.child("Shared").childByAutoId()
                    collabPath.setValue(data)
                    collabPath.updateChildValues([user.uid:user.displayName])
                    let autoID = collabPath.key
                    self.mainAutoKey = autoID
                    //print(self.mainAutoKey)
                    
                    for index in selectedRows! {
                        let specUID = self.uid[index.row]
                        ref.child("Shared").child(self.mainAutoKey).updateChildValues([specUID: self.users[index.row].name])
                    }
                }
                
                //                let newVC = self.storyboard?.instantiateViewController(withIdentifier: "home") as! ExperimentHomeViewController
                //                self.present(newVC, animated: false, completion: nil)
                //let previousVC = self.navigationController?.viewControllers.first as! ExperimentHomeViewController
                //previousVC.collabAutoKey = self.mainAutoKey
                //print(self.mainAutoKey)
                let test = self.navigationController?.viewControllers[0]
                self.navigationController?.popToViewController(test!, animated: true)
                //self.navigationController?.popToRootViewController(animated: true)
            })
            
            pathToExp.removeValue()
        }
        
    }
}

//extension InviteCollabViewController: UISearchBarDelegate {
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchActive = true
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchActive = false
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchActive = false
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchActive = false
//    }
////    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
////        filteredUsers = searchText.isEmpty ? users: users.filter({ (dataString: UsersStruct) -> Bool in
////            return dataString.range(of: searchText, options: .caseInsensitive) != nil
////        })
////    }
//}

extension InviteCollabViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.emailLabel.text = users[indexPath.row].email
        cell.diplayLabel.text = users[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRows.append(users[indexPath.row])
    }
}
