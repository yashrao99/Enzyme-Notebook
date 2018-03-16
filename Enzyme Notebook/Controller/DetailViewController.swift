//
//  DetailViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/7/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //OUTLETS
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var observationTextView: UITextView!
    @IBOutlet weak var whatDidUDoText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var hrsField: UITextField!
    @IBOutlet weak var hrsLabel: UILabel!
    @IBOutlet weak var minField: UITextField!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secField: UITextField!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var setNotifButton: UIButton!
    @IBOutlet weak var notificationText: UITextField!
    
    //GENERAL VARIABLES
    var storageRef: StorageReference!
    var experimentTitle: String!
    var dbRef: DatabaseReference!
    var arrayURL: [String] = []
    fileprivate var _refHandle: DatabaseHandle!
    var autoKey: String!
    var imageCache = NSCache<NSString,UIImage>()
    var photoKeys : [String] = []
    var test: String!
    
    //DATA PASSED FROM SPECIFIC CELL
    var cellTitle: String!
    var cellWhatUDid: String!
    var cellObservations: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNotifications()
        configureUI()
        configureStorage()
        configureCollectionView()
        configureButton()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.arrayURL.removeAll()
            self.downloadImagesAtStart()
            }
        }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        let creationDate = Date()
        let newDate = creationDate.string(with: "MMM dd, yyyy")
        
        if let user = Auth.auth().currentUser {
            let keyPath = Database.database().reference().child("Experiment").child((user.uid)).child(self.autoKey).child(self.titleText.text!)
            keyPath.updateChildValues(["Title": self.titleText.text, "Experimental" : self.whatDidUDoText.text, "Observations" : self.observationTextView.text, "creationDate" : "\(newDate)"])
        }        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openCameraButton(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("No camera")
        }
    }

    @IBAction func cancelPressed(_ sender: Any) {
        
        if self.titleText.text == "" || (self.titleText.text?.isEmpty)! {
            self.navigationController?.popViewController(animated: true)
        } else {
            var cancelAlert = UIAlertController(title: "Cancel Experimental Event", message: "All data will be lost", preferredStyle: .alert)
            cancelAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action:UIAlertAction!) in
                
                if let user = Auth.auth().currentUser {
                    
                    let databaseRef = Database.database().reference().child("Experiment").child(user.uid).child(self.autoKey)
                    print(databaseRef)
                    if let title = self.titleText.text {
                        print(title)
                        databaseRef.child(title).removeValue()
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }))
            cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(cancelAlert, animated: true, completion: nil)
        }
    }
 
    @IBAction func setNotification(_ sender: Any) {
        
        let hrsInt : Int? = Int(hrsField.text!) ?? 0
        let minInt: Int? = Int(minField.text!) ?? 0
        let secInt: Int? = Int(secField.text!) ?? 0
        
        if !(hrsField.text?.isEmpty)! || !(minField.text?.isEmpty)! || !(secField.text?.isEmpty)!{
            let hrsInt = hrsInt! * 60 * 60
            let minInt = minInt! * 60
            let secInt = secInt!
            
            let timeTotalInSec = hrsInt + minInt + secInt
            
            timedNotifications(inTime: TimeInterval(timeTotalInSec), completion: { (success) in
                if success {
                    print("success")
                }
            })
        } else {
            let alertView = UIAlertController(title: "Please enter valid times", message: "You left every time blank", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Return", style: .default, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertView, animated: true, completion: nil)
        }
    }

    func setUpNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            
            if error != nil {
                print("Authorization Unsuccessful")
            } else {
                print("Authorization works")
            }
        }
    }
    
    func timedNotifications(inTime: TimeInterval, completion: @escaping (_ success: Bool) -> ()) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inTime, repeats: false)
        
        let content = UNMutableNotificationContent()
        
        content.title = self.titleText.text!
        content.subtitle = "Enzymatiq Notification Request"
        if notificationText.text != Constants.textViewText.notificationTxt {
            content.body = notificationText.text!
        } else {
            content.body = "Please check on your experiment!"
        }
        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(chosenImage, 0.8) {
            uploadPhotoToFirebase(photoData: photoData)
            self.arrayURL.removeAll()
        }
        dismiss(animated: true, completion: nil)
    }

    func configureStorage() {
        storageRef = Storage.storage().reference()
    }

    func uploadPhotoToFirebase(photoData: Data) {
    
        if let user = Auth.auth().currentUser {
            print(self.experimentTitle)
            let imagePath = "ExpPhotos/" + user.uid + "/" + self.experimentTitle + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            self.confirmButton.isEnabled = false
            metadata.contentType = "image/jpeg"
            storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            let downloadURL = metadata?.downloadURL()?.absoluteString
                let databaseRef = Database.database().reference().child("Experiment").child(user.uid).child(self.autoKey).child(self.titleText.text!).childByAutoId()
                let photoKey = databaseRef.key
                self.photoKeys.append(photoKey)
                databaseRef.setValue(["photoURL":downloadURL], withCompletionBlock: { (error, snapshot) in
                    if error != nil {
                        print("Error :\(error)")
                    } else {
                        print("Completed")
                }
            })
            self.confirmButton.isEnabled = true
            //self.arrayURL.removeAll()
            }
        }
    }

    func downloadImagesAtStart() {
    
        if let user = Auth.auth().currentUser{
        
            if self.titleText.text != "" {
                Database.database().reference().child("Experiment").child(user.uid).child(self.autoKey).child(self.titleText.text!).observe(.childAdded, with: { (snapshot) in
                    if snapshot.exists() {
                        print(snapshot)
                        for snap in snapshot.children.allObjects {
                            let id = snap as! DataSnapshot
                            let snapVal = snapshot.value as! [String:AnyObject]
                            let url = snapVal["photoURL"] as! String
                            
                            DispatchQueue.main.async {
                                self.arrayURL.append(url)
                                print(self.arrayURL.count)
                                self.photoCollection.reloadData()
                            }
                        }
                    } else {
                        print("No images")
                    }
                })
                
            }
        }
    }
 /*
    func configureCancel() {
        if sentCancel != nil {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
   */
    func configureButton() {
        if titleText.text == nil || (titleText.text?.isEmpty)! {
            confirmButton.isEnabled = false
        } else {
            confirmButton.isEnabled = true
        }
    }
    
    func configureUI() {
        
        observationTextView.text = Constants.textViewText.detailTextView2
        whatDidUDoText.text = Constants.textViewText.detailTextView1
        titleText.placeholder = Constants.textViewText.detailText
        notificationText.placeholder = Constants.textViewText.notificationTxt
        
        whatDidUDoText.textColor = UIColor.lightGray
        observationTextView.textColor = UIColor.lightGray
        
        observationTextView.delegate = self
        whatDidUDoText.delegate = self
        titleText.delegate = self
        notificationText.delegate = self
        
        titleText.textAlignment = .center
        
        observationTextView.layer.borderColor = UIColor(red:0.21, green:0.79, blue:0.87, alpha:1.0).cgColor
        observationTextView.layer.borderWidth = 2.3
        observationTextView.layer.cornerRadius = 15
        whatDidUDoText.layer.borderColor = UIColor(red:0.21, green:0.79, blue:0.87, alpha:1.0).cgColor
        whatDidUDoText.layer.borderWidth = 2.3
        whatDidUDoText.layer.cornerRadius = 15
        /*
        titleText.layer.borderColor = UIColor(red:0.21, green:0.79, blue:0.87, alpha:1.0).cgColor
        titleText.layer.borderWidth = 2.3
        titleText.layer.cornerRadius = 15
        notificationText.layer.borderColor = UIColor(red:0.21, green:0.79, blue:0.87, alpha:1.0).cgColor
        notificationText.layer.borderWidth = 2.3
        notificationText.layer.cornerRadius = 15
        */
        setNotifButton.backgroundColor = UIColor.red
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCameraButton))
        self.navigationItem.rightBarButtonItem = cameraButton
        cameraButton.isEnabled = false
        self.navigationItem.title = "Details"
        
        if cellTitle != nil {
            titleText.text = cellTitle
            titleText.textColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        if cellObservations != nil {
            observationTextView.text = cellObservations
            observationTextView.textColor = UIColor.black
        }
        if cellWhatUDid != nil {
            whatDidUDoText.text = cellWhatUDid
            whatDidUDoText.textColor = UIColor.black
        }
        
        if test != nil {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
}

extension DetailViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == whatDidUDoText {
            if textView.text.isEmpty {
                textView.text = "Describe what you did!!"
                textView.textColor = UIColor.gray
            }
        }
        if textView == observationTextView {
            if textView.text.isEmpty {
                textView.text = "List any observations you may have had!!"
                textView.textColor = UIColor.gray
            }
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureCollectionView() {
        photoCollection.dataSource = self
        photoCollection.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayURL.count == 0 {
            return 3
        } else {
         return self.arrayURL.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        if self.arrayURL.count == 0 {
            cell.noPhotoLabel.isHidden = false
            cell.activityIndicator.isHidden = true
            return cell
        } else {
            cell.noPhotoLabel.isHidden = true
        }
        
        print(self.arrayURL.count)
        
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        var stringURL = arrayURL[indexPath.row]
        cell.imageView.loadImageUsingCacheWithURLString(urlString: stringURL)
        cell.activityIndicator.stopAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/3.0
        let yourHeight = yourWidth
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == Constants.textViewText.detailText {
            textField.text = ""
            textField.textColor = UIColor.black
        } else {
            textField.textColor = UIColor.black
            }
        
        if textField == notificationText {
                textField.text = ""
                textField.textColor = UIColor.black
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == titleText {
            if (textField.text?.isEmpty)! {
                textField.text = Constants.textViewText.detailText
                textField.textColor = UIColor.gray
            }
            if !(textField.text?.isEmpty)! {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }

        if textField == notificationText {
            if (textField.text?.isEmpty)! {
                textField.text = Constants.textViewText.notificationTxt
                textField.textColor = UIColor.gray
            }
        }
        configureButton()
    }
}
