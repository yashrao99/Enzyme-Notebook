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
        imageViewBackground.image = UIImage(named: "Ribo_app_titlescreen")
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        let loginLabel = UILabel(frame: CGRect(x: 0, y: 25, width:UIScreen.main.bounds.size.width, height: 150))
        loginLabel.text = "Your Experimental Notebook"
        loginLabel.textAlignment = .center
        loginLabel.textColor = UIColor.white
        loginLabel.font = UIFont(name: "Papyrus", size: 28.0)
        
        view.insertSubview(imageViewBackground, at: 0)
        view.insertSubview(loginLabel, at: 1)
        
        self.navigationItem.leftBarButtonItem = nil
    }
}
