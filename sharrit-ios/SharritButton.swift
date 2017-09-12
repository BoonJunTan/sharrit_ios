//
//  SharritButton.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

@IBDesignable
class SharritButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = Colours.Blue.skyBlueColor
        self.setTitleColor(UIColor.black, for: .normal)
    }
    
    @IBInspectable var isRounded: Bool = false {
        didSet{
            updateCornerRadius()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            updateCornerRadius()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black{
        didSet{
            updateBorderColor()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
            
        }
    }
    
    func updateCornerRadius(){
        if isRounded {
            // Set corner radius based on height or width
            layer.cornerRadius = cornerRadius
        }
    }
    
    func updateBorderColor(){
        layer.borderColor = borderColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
