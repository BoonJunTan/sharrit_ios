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

class MessagesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var chats: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let navBarClose = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMessages))
        self.navigationItem.leftBarButtonItem = navBarClose
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
        
        self.navigationController?.navigationBar.barTintColor = NavBarUI().getNavBar()
        
        chats.append(Message(id: "1", name: "Test"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeMessages() {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
        /*
        cell.iconLabel.text = tableViewItems[indexPath.section][indexPath.row]
        cell.iconImage.image = tableViewIcons[indexPath.section][indexPath.row]
        */
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        switch tableViewItems[indexPath.section][indexPath.row] {
        case "View as Sharror":
            tableViewItems[indexPath.section][indexPath.row] = "View as Sharries"
            switchRole()
            break
        case "View as Sharries":
            tableViewItems[indexPath.section][indexPath.row] = "View as Sharror"
            switchRole()
            break
        case "Logout":
            logoutPressed()
            break
        default:
            break
        }
        tableView.reloadData()
        */
        let chat = chats[indexPath.row]
        performSegue(withIdentifier: "conversationIdentifier", sender: chat)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let chat = sender as? Message {
            let chatVC = segue.destination as! ConversationVC
            
            //chatVC.senderDisplayName = senderDisplayName
            chatVC.chat = chat
        }
    }
    
}
