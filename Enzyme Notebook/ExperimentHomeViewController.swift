//
//  ExperimentHomeViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/4/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import Firebase

class ExperimentHomeViewController: UIViewController, AuthUIDelegate, UINavigationControllerDelegate, FUIAuthDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _refHandle: DatabaseHandle!
    var user: User?
    var displayName: String? = ""
    var ref: DatabaseReference!
    var experiments : [DataSnapshot]! = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureUI()
        configureDatabase()
        
        
    }
    
    func configureAuth() {
        
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                    self.ref.child("users").child(activeUser.uid).setValue(["Display Name": "\(name)", "Email": "\(activeUser.email!)", "Provider" : "\(activeUser.providerID)"])
                }
            } else {
                self.loginSession()
            }
        }
    }
    
    func loginSession() {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self as FUIAuthDelegate
        let authViewController = CustomAuthViewController(authUI: authUI!)
        let navc = UINavigationController(rootViewController: authViewController)
        self.present(navc, animated: true, completion: nil)
        
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
        _refHandle = ref.child("Experiment").observe(.childAdded) { (snapshot: DataSnapshot) in
            self.experiments.append(snapshot)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureUI() {
        let rightButton = UIBarButtonItem(title: "New Experiment", style: .plain, target: self, action: #selector(self.startNewExperiment))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let leftbutton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        self.navigationItem.leftBarButtonItem = leftbutton
        
        self.navigationItem.title = "Home"
    }
    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Unable to sign out: \(error)")
        }
    }
    
    @objc func startNewExperiment() {
        performSegue(withIdentifier: "newExperiment", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "newExperiment" {
            let vc = segue.destination as! NewExperimentalViewController
            vc.navigationItem.title = "New Experiment"
            vc.user = self.user
        }
    }

}

