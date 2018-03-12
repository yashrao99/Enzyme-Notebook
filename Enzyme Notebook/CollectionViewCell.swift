//
//  CollectionViewCell.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/9/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoLabel: UILabel!
    
    
    

    
    /*
    func getImage(_ photoArray: [UIImage]) {
        
        if photoArray.count != 0 {
            for photo in photoArray {
                print(photo)
                DispatchQueue.main.async {
                    self.imageView.image = photo
                }
                
            }
        }
    } */
}
