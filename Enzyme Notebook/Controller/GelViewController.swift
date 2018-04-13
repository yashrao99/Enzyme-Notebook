//
//  GelViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/22/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit


class GelViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noPhotoLabel: UILabel!
    @IBOutlet weak var stackLabel: UILabel!
    @IBOutlet weak var shrinkButton: UIButton!
    @IBOutlet weak var wideButton: UIButton!
    @IBOutlet weak var buttonStack: UIStackView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var buttonsHidden = false
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 5.0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let value = UIInterfaceOrientation.landscapeLeft.rawValue
       // UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isHidden = true
        configureUI()
        self.brushSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        swiped = false
        
        if let touch = touches.first as UITouch? {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        swiped = true
        
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.location(in: view)
            drawLine(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if !swiped {
            drawLine(lastPoint, toPoint: lastPoint)
        }
    }
    
    func drawLine(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
       
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1)
        context?.setBlendMode(CGBlendMode.normal)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func configureUI() {
        
        //self.navigationItem.title = "Annotate"
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCameraButton))
        let activityButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pick))
        let clearButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearImage))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        let hideButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(hideStack))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spaceButton.width = 35
    
        self.navigationItem.rightBarButtonItems = [cameraButton, spaceButton, clearButton, spaceButton, hideButton, spaceButton, activityButton, spaceButton, saveButton]
        //self.navigationItem.leftBarButtonItems = []
        
        //self.noPhotoLabel.text = "Annotate your images here. Buttons on toolbar in order: save, add Photo, hide toolBar, reset image, open camera"
    }
    
    func imagePriorities(_ imageView: UIImageView) {
        if imageView.bounds.width > imageView.bounds.height {
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView.contentMode = .scaleAspectFill
        }
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
    
    @objc func hideStack() {
        buttonsHidden = !buttonsHidden
        if buttonsHidden == false {
            buttonStack.isHidden = false
        } else if buttonsHidden == true {
            buttonStack.isHidden = true
        }
    }
    
    @objc func clearImage() {
        if imageView.image != nil {
            noPhotoLabel.isHidden = false
            imageView.image = nil
        }
    }
    
    @objc func save() {
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activity = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func redButton(_ sender: Any) {
        
        (red, green, blue) = (255, 0, 0)
    }
    
    @IBAction func greenButton(_ sender: Any) {
        
        (red, green, blue) = (0, 255, 0)
    }
    
    @IBAction func blueButton(_ sender: Any) {
        
        (red, green, blue) = (0, 0 , 255)
    }
    
    @IBAction func blackButton(_ sender: Any) {
        
        (red, green, blue) = (0, 0, 0)
    }
    
    @IBAction func shrinkButton(_ sender: Any) {
        
        brushWidth -= 1
        self.brushSize()
    }
    
    func brushSize() {

        stackLabel.text = String(format: "%.0f", brushWidth)
        
        if brushWidth == 100 {
            wideButton.isEnabled = false
            wideButton.alpha = 0.25
            
        } else if brushWidth == 0 {
            shrinkButton.isEnabled = false
            shrinkButton.alpha = 0.25
        
        } else {
            wideButton.isEnabled = true
            shrinkButton.isEnabled = true
            wideButton.alpha = 1
            shrinkButton.alpha = 1
        }
    }
    
    @IBAction func wideButton(_ sender: Any) {
        
        brushWidth += 1
        self.brushSize()
    }
}

extension GelViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func pick(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        
        self.imageView.image = nil
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            DispatchQueue.main.async {
                self.noPhotoLabel.isHidden = true
                self.imageView.isHidden = false
                self.imageView.image = chosenImage
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            }
        }
        dismiss(animated: true, completion: nil)
    }
}



