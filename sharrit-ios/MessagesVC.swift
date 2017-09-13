//
//  Messages.swift
//  sharrit-ios
//
//  Created by Boon Jun on 13/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class MessagesVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        
        let navBarClose = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMessages))
        
        self.navigationItem.leftBarButtonItem = navBarClose
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeMessages() {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true, completion: nil)
    }
    
}
