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
        self.imageView.image = nil
        if urlForPic != nil {
          self.imageView.loadImageUsingCacheWithURLString(urlString: urlForPic)
          self.imageView.contentMode = .scaleAspectFit
        }
    }
}
