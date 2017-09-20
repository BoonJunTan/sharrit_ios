//
//  SharrorFormVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SharrorFormVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var questionCollectionView: UICollectionView!
    var companyName: String!
    
    var questions:[String] = ["How are you?", "Where do you stay?", "Please explain why you want to join us", "Other opportunity?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Sharror - " + companyName
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath as IndexPath) as! SharrorFormCollectionViewCell
        
        cell.questionLabel.text = questions[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: questionCollectionView.layer.frame.width,
                      height: questionCollectionView.layer.frame.height/3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if (section == 0) {
            return CGSize(width: questionCollectionView.layer.frame.width, height: 50)
        }
        return CGSize(width: questionCollectionView.layer.frame.width, height: 50 + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath as IndexPath)
        
        return footerView
    }
    
    @IBAction func submitFormBtnTapped(_ sender: SharritButton) {
        
    }
    
}
