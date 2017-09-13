//
//  Messages.swift
//  sharrit-ios
//
//  Created by Boon Jun on 13/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

enum MessageType {
    case All
    case Sharries
    case Sharror
}

class MessagesVC: UIViewController {
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var sharriesBtn: UIButton!
    @IBOutlet weak var sharrorBtn: UIButton!
    
    var currentMessageType = MessageType.All {
        didSet {
            switch currentMessageType {
            case .All:
                btnPressedDesign(button: allBtn)
                btnNotPressedDesign(button: sharriesBtn)
                btnNotPressedDesign(button: sharrorBtn)
                break
            case .Sharries:
                btnPressedDesign(button: sharriesBtn)
                btnNotPressedDesign(button: allBtn)
                btnNotPressedDesign(button: sharrorBtn)
                break
            case .Sharror:
                btnPressedDesign(button: sharrorBtn)
                btnNotPressedDesign(button: allBtn)
                btnNotPressedDesign(button: sharriesBtn)
                break
            }
        }
    }
    
    func btnPressedDesign(button: UIButton) {
        button.backgroundColor = Colours.Blue.sharritBlue
        button.setTitleColor(UIColor.black, for: .normal)
    }
    
    func btnNotPressedDesign(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let navBarClose = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMessages))
        self.navigationItem.leftBarButtonItem = navBarClose
        
        setupBtnBorder(allBtn);
        setupBtnBorder(sharriesBtn);
        setupBtnBorder(sharrorBtn);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBtnBorder(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = Colours.Blue.sharritBlue.cgColor
    }
    
    func closeMessages() {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func allBtnPressed(_ sender: UIButton) {
        currentMessageType = .All
    }
    
    @IBAction func sharriesBtnPressed(_ sender: UIButton) {
        currentMessageType = .Sharries
    }
    
    @IBAction func sharrorBtnPressed(_ sender: UIButton) {
        currentMessageType = .Sharror
    }
    
}
