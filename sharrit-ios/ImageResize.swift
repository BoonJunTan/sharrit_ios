//
//  ImageResize.swift
//  sharrit-ios
//
//  Created by Boon Jun on 2/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

struct ImageResize {
    func resizeImageWith(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
