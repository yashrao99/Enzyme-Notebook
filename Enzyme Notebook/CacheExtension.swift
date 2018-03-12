//
//  CacheExtension.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/11/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString,UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithURLString(urlString: String) {
                
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            
            guard (error == nil) else {
                print("Error with data task")
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }
        .resume()
    }
}
