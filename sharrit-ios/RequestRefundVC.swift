//
//  RequestRefundVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 9/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestRefundVC: UIViewController {

    // Pass over data
    var sharreTitle: String!
    var transactionID: Int!
    
    @IBOutlet weak var sharreTitleLabel: UILabel!
    @IBOutlet weak var reasonTV: UITextView!
    
    @IBOutlet weak var reasonError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reasonError.isHidden = true
        sharreTitleLabel.text = sharreTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestBtnPressed(_ sender: SharritButton) {
        if reasonTV.text.isEmpty {
            reasonError.isHidden = false
        }
        
        let url = SharritURL.devURL + "transaction/refund/" + String(describing: transactionID!)
        
        let refundData: [String: Any] = ["reason": reasonTV.text!]
        
        Alamofire.request(url, method: .post, parameters: refundData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(_):
                print("Submit Refund API failed")
                break
            }
        }
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
