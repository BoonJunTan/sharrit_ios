//
//  Messages.swift
//  sharrit-ios
//
//  Created by Boon Jun on 13/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum MessageType {
    case All
    case Sharries
    case Sharror
}

class MessagesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var chats: [Conversation] = []
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var sharrieBtn: UIButton!
    @IBOutlet weak var sharrorBtn: UIButton!
    
    var messageType: MessageType = .All {
        didSet {
            switch messageType {
            case .All:
                break
            case .Sharries:
                break
            case .Sharror:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let navBarClose = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMessages))
        self.navigationItem.leftBarButtonItem = navBarClose
        
        setupBtnUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
        
        getAllConversation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeMessages() {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupBtnUI() {
        allBtn.layer.borderColor = Colours.Blue.sharritBlue.cgColor
        allBtn.layer.borderWidth = 1
        currentBtnSelected(btn: allBtn)
        sharrieBtn.layer.borderColor = Colours.Blue.sharritBlue.cgColor
        sharrieBtn.layer.borderWidth = 1
        sharrorBtn.layer.borderColor = Colours.Blue.sharritBlue.cgColor
        sharrorBtn.layer.borderWidth = 1
    }
    
    func currentBtnSelected(btn: UIButton) {
        btn.backgroundColor = Colours.Blue.sharritBlue
        btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func defaultBtnUI() {
        allBtn.backgroundColor = UIColor.white
        allBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        sharrieBtn.backgroundColor = UIColor.white
        sharrieBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        sharrorBtn.backgroundColor = UIColor.white
        sharrorBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    func getAllConversation() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let url: String!
        
        switch messageType {
        case .All:
            url = SharritURL.devURL + "conversation/user/" + String(describing: appDelegate.user!.userID)
            break
        case .Sharries:
            url = SharritURL.devURL + "conversation/sharrie/" + String(describing: appDelegate.user!.userID)
            break
        case .Sharror:
            url = SharritURL.devURL + "conversation/sharror/" + String(describing: appDelegate.user!.userID)
            break
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.chats.removeAll()
                    for (_, subJson) in JSON(data) {
                        self.chats.append(Conversation(id: Int(subJson["conversationId"].description)!, conversationPartner: subJson["senderName"].description, latestMessage: subJson["body"].description, subjectTitle: subJson["subject"].description, lastestMessageDate: subJson["dateCreated"].description))
                    }
                    self.tableView.reloadData()
                }
                break
            case .failure(_):
                print("Get Conversation API failed")
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
        cell.itemTitle.text = chats[indexPath.row].subjectTitle
        cell.profileName.text = chats[indexPath.row].conversationPartner
        cell.messageLabel.text = chats[indexPath.row].latestMessage
        
        // Format Date
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let messageDate = dateFormatter2.date(from: chats[indexPath.row].lastestMessageDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        cell.messageDate.text = dateFormatter.string(from: messageDate!)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        performSegue(withIdentifier: "conversationIdentifier", sender: chat)
    }
    
    @IBAction func allBtnPressed(_ sender: UIButton) {
        messageType = .All
        defaultBtnUI()
        currentBtnSelected(btn: allBtn)
        getAllConversation()
    }
    
    @IBAction func sharrieBtnPressed(_ sender: UIButton) {
        messageType = .Sharries
        defaultBtnUI()
        currentBtnSelected(btn: sharrieBtn)
        getAllConversation()
    }
    
    @IBAction func sharrorBtnPressed(_ sender: UIButton) {
        messageType = .Sharror
        defaultBtnUI()
        currentBtnSelected(btn: sharrorBtn)
        getAllConversation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let chat = sender as? Conversation {
            let chatVC = segue.destination as! ConversationVC
            
            chatVC.senderDisplayName = chat.conversationPartner
            chatVC.chat = chat
        }
    }
    
}
