//
//  SharreTimeUsageVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 29/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharreTimeUsageVC: UIViewController {

    // Pass Over Data
    var sharreID: Int!
    var sharreTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = sharreTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
