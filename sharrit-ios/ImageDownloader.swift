//
//  ImageDownloader.swift
//  sharrit-ios
//
//  Created by Boon Jun on 26/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

struct ImageDownloader {
    func imageFromServerURL(urlString: String, imageView: UIImageView) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                if let image = UIImage(data: data!) {
                    imageView.image = ImageResize().resizeImageWith(image: image, newWidth: imageView.layer.frame.width)
                } else {
                    imageView.image = #imageLiteral(resourceName: "empty")
                }
            })
        }).resume()
    }
    
    func imageFromServerURL(urlString: String, completion: @escaping (_ result: UIImage) -> Void) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                return
            }
            if let image = UIImage(data: data!) {
                completion(image)
            } else {
                completion(#imageLiteral(resourceName: "empty"))
            }
        }).resume()
    }
}
