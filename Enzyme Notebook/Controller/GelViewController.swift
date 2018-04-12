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
    
    var lastPoint = CGPoint.zero
    var swiped = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let value = UIInterfaceOrientation.landscapeLeft.rawValue
       // UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isHidden = true
        configureUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        
        if let touch = touches.first as UITouch! {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first as UITouch! {
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
        context?.setLineWidth(5.0)
        context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context?.setBlendMode(CGBlendMode.normal)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func configureUI() {
        
        self.navigationItem.title = "Gel Analayzer"
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCameraButton))
        let activityButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(pick))
        
        self.navigationItem.rightBarButtonItem = cameraButton
        self.navigationItem.leftBarButtonItem = activityButton
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
    
    func clearImage() {
        if imageView.image != nil {
            imageView.image = nil
        }
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
            }
        }
        dismiss(animated: true, completion: nil)
    }
}



