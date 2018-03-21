//
//  ImageViewerViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/19/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit

class ImageViewerViewController : UIViewController {
    
    @IBOutlet weak var imageView : UIImageView!
    
    var urlForPic: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
        self.navigationItem.rightBarButtonItem = shareBarButton
        
        self.navigationItem.title = "View Image"
                
        self.imageView.image = nil
        if urlForPic != nil {
          self.imageView.loadImageUsingCacheWithURLString(urlString: urlForPic)
          self.imageView.contentMode = .scaleAspectFit
        }
    }
    
    //Opens up activityViewIndicator to share images
    
    @objc func shareImage() {
        
        let image = imageView.image
        
        let imageToShare = [image!]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.excludedActivityTypes = [ UIActivityType.postToFacebook, UIActivityType.mail ]

    }
}
