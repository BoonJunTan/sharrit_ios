//
//  SmartCardVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 23/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SmartCardVC: UIViewController {
    
    @IBOutlet weak var requestStatus: UITextView!
    @IBOutlet weak var requestDate: UILabel!
    @IBOutlet weak var requestBtn: SharritButton!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getCardDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCardDetails() {
        let url = SharritURL.devURL + "smartcard/user/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                
            case .success(_):
                if let data = response.result.value {
                    if !JSON(data)["content"].array!.isEmpty {
                        if JSON(data)["content"][0]["status"].int! == 0 {
                            self.requestStatus.text = "Your request is currently on pending, please check the status later again. Cheers!"
                        } else {
                            self.requestStatus.text = "Your card is mailed, please check your mailbox in 3-5 days time. Cheers!"
                        }
                        self.requestDate.text = FormatDate().formatDateTimeToLocal3(date: JSON(data)["content"][0]["dateCreated"].description)
                        self.requestBtn.isHidden = true
                    } else {
                        self.requestStatus.text = "Not Yet Requested"
                        self.requestDate.text = "Not Yet Requested"
                        self.requestBtn.isHidden = false
                    }
                }
                break
            case .failure(_):
                print("Retrieve Smart Card Details API failed")
                break
            }
        }
    }

    @IBAction func requestBtnPressed(_ sender: SharritButton) {
        let url = SharritURL.devURL + "smartcard/user/request/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                
            case .success(_):
                if let data = response.result.value {
                    self.getCardDetails()
                }
                break
            case .failure(_):
                print("Request Smart Card Details API failed")
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
