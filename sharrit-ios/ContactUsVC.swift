//
//  ContactUsVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 21/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire

class ContactUsVC: UIViewController {
    
    @IBOutlet weak var subjectLabel: UITextField!
    @IBOutlet weak var messageText: UITextView!
    
    @IBOutlet weak var errorView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
    }
    
    @IBAction func sendBtnTapped(_ sender: SharritButton) {
        if (subjectLabel.text?.isEmpty)! || (messageText.text?.isEmpty)! {
            errorView.isHidden = false
        } else {
            errorView.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let messageData: [String: Any] = ["subject": subjectLabel.text!, "senderId": appDelegate.user!.userID, "senderType": 0, "receiverType": 3 , "receiverId": 0, "senderName": appDelegate.user!.firstName + " " + appDelegate.user!.lastName, "body" : messageText.text]
            
            let url = SharritURL.devURL + "conversation"
            
            Alamofire.request(url, method: .post, parameters: messageData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    self.performSegue(withIdentifier: "showConversation", sender: nil)
                    break
                case .failure(_):
                    print("Create conversation API failed")
                    break
                }
            }
        }
    }
    
}
