//
//  WalletVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WalletVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var walletAmtLabel: UILabel!
    
    var btnIcon = [#imageLiteral(resourceName: "transaction"),#imageLiteral(resourceName: "deposit"),#imageLiteral(resourceName: "smart_card"), #imageLiteral(resourceName: "withdrawl")]
    var btnLabel = ["History", "Top Up", "Smart Card", "Cash Out"]
    @IBOutlet weak var btnCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return btnLabel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walletBtnCell", for: indexPath as IndexPath) as! ButtonCollectionViewCell
        
        cell.btnIcon.image = btnIcon[indexPath.item]
        cell.btnLabel.text = btnLabel[indexPath.item]
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: btnCollectionView.layer.frame.width/2 - 1, height: btnCollectionView.layer.frame.height/2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch btnLabel[indexPath.item] {
        // Must TODO : 2nd System Release
        case "Top Up", "Cash Out":
            performSegue(withIdentifier: "walletTopUp", sender: btnLabel[indexPath.item])
            break
        case "History":
            performSegue(withIdentifier: "viewAllTransaction", sender: nil)
            break
        default:
            break
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "walletTopUp" {
            if let walletManagementVC = segue.destination as? WalletTopUpVC {
                sender as! String == "Top Up" ? (walletManagementVC.walletManagement = .TopUp) : (walletManagementVC.walletManagement = .CashOut)
            }
        }
    }
    
}
