//
//  SharresCreationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharresCreationVC: UIViewController {

    // Pass Over Data
    var sharreTitle: String!
    var sharreID: Int!
    
    @IBOutlet weak var sharreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sharreLabel.text = sharreTitle
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "viewSharre", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharre" {
            if let viewSharreVC = segue.destination as? ViewSharreVC {
                viewSharreVC.sharreID = sharreID
            }
        }
    }

}
