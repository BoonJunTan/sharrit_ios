//
//  CollaborationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 8/11/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollaborationVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Pass Over Data
    var collaborationList: [JSON]!
    
    @IBOutlet weak var collaborationCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set up all necessary component for Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collaborationList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collaborationCell", for: indexPath as IndexPath) as! CollaborationCollectionViewCell
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collaborationCollectionView.layer.frame.width - 5,
                      height: collaborationCollectionView.layer.frame.height - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = collaborationCollectionView.layer.frame.width - 5
        let totalCellHeight = collaborationCollectionView.layer.frame.height - 5
        
        let leftInset = (collaborationCollectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        let topInset = (collaborationCollectionView.layer.frame.height - CGFloat(totalCellHeight)) / 2
        let btnInset = topInset
        
        return UIEdgeInsetsMake(topInset, leftInset, btnInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedCategory = [String : Any]()
        
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
