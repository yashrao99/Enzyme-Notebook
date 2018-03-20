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
    
    //OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var mainView: UIView!
    
    //VARIABLES
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _refHandle: DatabaseHandle!
    var user: User?
    var displayName: String? = ""
    var ref: DatabaseReference!
    var experiments : [ExperimentStruct]! = []
    var arrayForDeletion : [DataSnapshot]! = []
    var arrayOfAutoKeys: [String]! = []
    var isSingedIn: Bool! = false
    
    var imageArray = ["mortface", "mortface2", "morty3"]
    
    //OVERRIDE FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureUI()
        configureDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        configureDatabase()
        if self.isSingedIn {
            loadCalls()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Pack info for child VC (newExperiment)
        if segue.identifier == "newExperiment" {
            let vc = segue.destination as! NewExperimentalViewController
            vc.navigationItem.title = "New Experiment"
            vc.user = self.user
            vc.tabBarController?.tabBar.isHidden = true
        }
        
        if segue.identifier == "toEvents" {
            let vc = segue.destination as! EventViewController
            let row = (sender as! IndexPath).row
            let expSnap = experiments[row]
            vc.expProtocol = expSnap.typedProtocol
            vc.startDate = expSnap.startDate
            vc.endDate = expSnap.endDate
            vc.navigationItem.title = "Events"
            vc.tabBarController?.tabBar.isHidden = true
            vc.expTitle = expSnap.title
            vc.autoKey = arrayOfAutoKeys[row]
        }
    }
    
    //CONVENIENCE FUNCTIONS
    
    func configureAuth() {
        //Set up the FirebaseAuth, only allow access if authenticated
        
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            self.experiments.removeAll()
            self.tableView.reloadData()
            
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                    self.ref.child("users").child(activeUser.uid).setValue(["Display Name": "\(name)", "Email": "\(activeUser.email!)", "Provider" : "\(activeUser.providerID)"])
                    self.loadCalls()
                    var isSignedIn = true
                }
            } else {
                self.loginSession()
                var isSingedIn = true
            }
        }
    }
    
    func loginSession() {
        //Present customAuthVC to allow for google/email sign-in
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self as FUIAuthDelegate
        let authViewController = CustomAuthViewController(authUI: authUI!)
        let navc = UINavigationController(rootViewController: authViewController)
        self.present(navc, animated: true, completion: nil)
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    deinit {
        //Remove handlers when VC is deinitialized
        ref.child("Experiment").removeObserver(withHandle: _refHandle)
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    func configureUI() {
        //UI deatils to save space
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(startNewExperiment))
        addBarButton.tintColor = UIColor(red:0.07, green:0.25, blue:0.05, alpha:1.0)
        self.navigationItem.rightBarButtonItem = addBarButton
        
        let leftbutton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        self.navigationItem.leftBarButtonItem = leftbutton
        
        self.navigationItem.title = "Enzymatic"
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 150.0
        self.tableView.backgroundColor = UIColor.clear
        
        self.tabBarController?.tabBar.isHidden = false
        
        let backgroundImg = UIImageView(frame: UIScreen.main.bounds)
        backgroundImg.image = UIImage(named: "portal")
        backgroundImg.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImg, at: 0)
    }
   
    func loadCalls() {
        
        //Pull info from firebase, unwrap, and get it in shape for tableView
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let pathKey = ref.child("Experiment").child(userID!).childByAutoId()
        let childAutoID = pathKey.key
        _refHandle = ref.child("Experiment").child(userID!).queryOrdered(byChild: childAutoID).observe(.childAdded, with: { (snapshot) in
            
            self.arrayForDeletion.append(snapshot)
            self.arrayOfAutoKeys.append(snapshot.key)
            let expDict = snapshot.value as! [String:AnyObject]
            let experiment = ExperimentStruct(dictionary: expDict)
            self.experiments.append(experiment!)
            self.tableView.insertRows(at: [IndexPath(row: self.experiments.count-1, section: 0)], with: .automatic)
            
           DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
}

extension ExperimentHomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experiments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "experimentCell", for: indexPath) as! ExperimentHomeCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.photoView.layer.cornerRadius = cell.photoView.frame.height / 2
        cell.photoView.layer.masksToBounds = true
        
        let randomIndex = Int(arc4random_uniform(UInt32(imageArray.count)))
        
        //Fill in TableView cell with info
        let expSnapshot = experiments[indexPath.row]
        cell.titleLabel.text = "Experiment: " + expSnapshot.title
        cell.creationLabel.text = "Created on: " + expSnapshot.creationDate
        cell.photoView.image = UIImage(named: imageArray[randomIndex])
        cell.imageView?.contentMode = .scaleAspectFit
        cell.backgroundColor = UIColor.clear
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //Delete from Firebase
            ref = Database.database().reference()
            let userID = Auth.auth().currentUser?.uid
            let fbRef = arrayForDeletion[indexPath.row]
            let deletionKey = (fbRef.key)
            let fbDbRef = ref.child("Experiment").child(userID!)
            fbDbRef.child(deletionKey).removeValue()
            
            //Delete from tableView
            self.experiments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            }
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toEvents", sender: indexPath)
    }
}

