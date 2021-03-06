//
//  CustomAuthViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/4/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuthUI

class CustomAuthViewController: FUIAuthPickerViewController, FUIAuthDelegate {
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "rick_title")
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill

        view.insertSubview(imageViewBackground, at: 0)
        
        self.navigationItem.leftBarButtonItem = nil
    }
}
