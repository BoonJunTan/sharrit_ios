//
//  ShowSharesInfoVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class ShowSharesInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var titleString: String!
    
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var historyBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewItems:[Shares] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = titleString
        
        defaultBtnUI()
        currentBtnSelected(btn: upcomingBtn)
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7 //tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharesInfoCell") as! SharesInfoTableViewCell
//        cell.sharesImage.image = tableViewItems[indexPath.row].
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "viewSharesInfo", sender: sharesCollection[indexPath.item])
    }
    
    func goToMessages() {
        let messageSB = UIStoryboard(name: "Messages" , bundle: nil)
        let messageVC = messageSB.instantiateViewController(withIdentifier: "messages") as! MessagesVC
        let messageWithNavController = UINavigationController(rootViewController: messageVC)
        
        messageWithNavController.modalTransitionStyle = .coverVertical
        modalPresentationStyle = .fullScreen
        present(messageWithNavController, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
    }
    
    func currentBtnSelected(btn: UIButton) {
        btn.backgroundColor = Colours.Blue.sharritBlue
        btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func defaultBtnUI() {
        upcomingBtn.backgroundColor = UIColor.white
        upcomingBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        historyBtn.backgroundColor = UIColor.white
        historyBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    @IBAction func upcomingBtnPressed(_ sender: Any) {
        defaultBtnUI()
        currentBtnSelected(btn: upcomingBtn)
    }
    
    @IBAction func historyBtnPressed(_ sender: Any) {
        defaultBtnUI()
        currentBtnSelected(btn: historyBtn)
    }
    
}
