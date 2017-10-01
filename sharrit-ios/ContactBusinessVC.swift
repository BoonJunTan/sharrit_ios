//
//  ContactBusinessVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 21/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire

class ContactBusinessVC: UIViewController {
    
    @IBOutlet weak var subjectLabel: UITextField!
    @IBOutlet weak var messageText: UITextView!
    
    @IBOutlet weak var errorView: UILabel!
    
    var sharingBusinessID: Int!
    var sharingBusinessName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        self.title = "Contact " + sharingBusinessName
    }
    
    @IBAction func sendBtnTapped(_ sender: SharritButton) {
        if (subjectLabel.text?.isEmpty)! || (messageText.text?.isEmpty)! {
            errorView.isHidden = false
        } else {
            errorView.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let messageData: [String: Any] = ["subject": subjectLabel.text!, "senderId": appDelegate.user!.userID, "senderType": 0, "receiverType": 2, "receiverId": sharingBusinessID, "senderName": appDelegate.user!.firstName + " " + appDelegate.user!.lastName, "body" : messageText.text!]
            
            let url = SharritURL.devURL + "conversation"
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + appDelegate.user!.accessToken,
                "Accept": "application/json" // Need this?
            ]
            
            Alamofire.request(url, method: .post, parameters: messageData, encoding: JSONEncoding.default, headers: headers).responseJSON {
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
