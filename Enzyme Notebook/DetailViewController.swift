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

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var observationTextView: UITextView!
    @IBOutlet weak var whatDidUDoText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    
    var storageRef: StorageReference!
    var experimentTitle: String!
    var dbRef: DatabaseReference!
    var downloadedImages: [UIImage] = []
    var arrayURL: [String] = []
    fileprivate var _refHandle: DatabaseHandle!
    var autoKey: String!
    var imageCache = NSCache<NSString,UIImage>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadedImages.removeAll()
        configureUI()
        configureStorage()
        configureCollectionView()
        downloadImagesAtStart()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.photoCollection.reloadData()
            }
        }
    
    func configureUI() {
        self.tabBarController?.tabBar.isHidden = true
        observationTextView.text = Constants.textViewText.detailTextView2
        whatDidUDoText.text = Constants.textViewText.detailTextView1
        observationTextView.textColor = UIColor.gray
        whatDidUDoText.textColor = UIColor.gray
        observationTextView.delegate = self
        whatDidUDoText.delegate = self
        titleText.delegate = self
        titleText.text = Constants.textViewText.titleText
        titleText.textColor = UIColor.gray
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCameraButton))
        self.navigationItem.rightBarButtonItem = cameraButton
        self.navigationItem.title = "Details"
        
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        print(autoKey)
        if let user = Auth.auth().currentUser {
            Database.database().reference().child("Experiment").child((user.uid)).child(autoKey).childByAutoId().setValue(["Title": self.titleText.text, "Experimental" : self.whatDidUDoText.text, "Observations" : self.observationTextView.text])
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    
    func configureDatabase() {
        dbRef = Database.database().reference()
    }
    
    func uploadPhotoToFirebase(photoData: Data) {
        
        if let user = Auth.auth().currentUser {
            let imagePath = "ExpPhotos/" + user.uid + "/" + self.experimentTitle + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                let downloadURL = metadata?.downloadURL()?.absoluteString
                let databaseRef = Database.database().reference().child("Photos").child(user.uid).child(self.experimentTitle).childByAutoId()
                databaseRef.setValue(["photoURL": downloadURL])
                print("Sucessfully uploaded image")
                self.arrayURL.removeAll()
            }
        }
    }
  
   func downloadImagesAtStart() {
        
        if let user = Auth.auth().currentUser{
            
            self.arrayURL.removeAll()
            _refHandle = Database.database().reference().child("Photos").child(user.uid).child(self.experimentTitle).observe(.value, with: { (snapshot) in
                
                for snap in snapshot.children.allObjects {
                    let id = snap as! DataSnapshot
                    if snapshot.exists() {
                        let snapVal = snapshot.value as! [String:AnyObject]
                        let layer2 = snapVal[id.key] as! [String:AnyObject]
                        let url = layer2["photoURL"] as! String
                        
                        DispatchQueue.main.async {
                            self.arrayURL.append(url)
                            print(self.arrayURL.count)
                            self.photoCollection.reloadData()
                        }
                    }
                }
            })
        }
    }

    deinit {
        Database.database().reference().child("Photos").removeAllObservers()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(chosenImage, 0.8) {
            uploadPhotoToFirebase(photoData: photoData)
            self.arrayURL.removeAll()
        }
        dismiss(animated: true, completion: nil)
    }
}


extension DetailViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.textViewText.genericText
            textView.textColor = UIColor.gray
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureCollectionView() {
        photoCollection.dataSource = self
        photoCollection.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        cell.activityIndicator.startAnimating()
        var stringURL = arrayURL[indexPath.row]
        cell.imageView.image = nil
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
    }
}
