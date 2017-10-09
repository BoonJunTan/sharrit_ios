//
//  ViewRefundVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 9/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewRefundVC: UIViewController {
    
    // Pass over data
    var transaction: Transaction!

    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var sharreTitleLabel: UILabel!
    @IBOutlet weak var refundReasonTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        transactionIDLabel.text = String(describing: transaction.transactionId)
        sharreTitleLabel.text = transaction.sharreName
        
        getRefundReason()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func approveBtnPressed(_ sender: UIButton) {
        let url = SharritURL.devURL + "transaction/refund/approve/" + String(describing: transaction.transactionId)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(_):
                print("Approve Refund API failed")
                break
            }
        }
    }
    
    @IBAction func refundBtnPressed(_ sender: UIButton) {
        let url = SharritURL.devURL + "transaction/refund/reject/" + String(describing: transaction.transactionId)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(_):
                print("Reject Refund API failed")
                break
            }
        }
    }
    
    func getRefundReason() {
        let url = SharritURL.devURL + "transaction/refund/reason/" + String(describing: transaction.transactionId)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.refundReasonTV.text = JSON(data)["content"].description
                }
                break
            case .failure(_):
                print("Refund Get Reason API failed")
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
