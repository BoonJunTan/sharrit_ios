//
//  SharreBookingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import FSCalendar

class SharreBookingVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Pass Over Data
    var sharreID: Int!
    var sharreTitle: String!
    var appointmentType: SharresType!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    var timeCollection: [String]! = [] // Operating Hours
    @IBOutlet weak var timeSlotView: UIView!
    @IBOutlet weak var timeSlotHeight: NSLayoutConstraint!
    
    @IBOutlet weak var costView: UIView!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // Automatically get local - E.g. Asia/Singapore (current time)
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = sharreTitle
        
        // The check is depends on if the Sharre is Time-usage based or Appointment based
        // If Time-usage then there is no calendar, else there is
        setUpCalendar()
        timeSlotView.isHidden = true
        costView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Setup Calendar - For Appointment Based
    func setUpCalendar() {
        if appointmentType == .DayAppointment {
            calendar.swipeToChooseGesture.isEnabled = true
            calendar.allowsMultipleSelection = true
        } else {
            calendar.swipeToChooseGesture.isEnabled = false
            calendar.allowsMultipleSelection = false
        }
    }
    
    // FSCalendar Delegate Method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Did select date \(self.formatter.string(from: date))")
        if appointmentType == .HrAppointment {
            timeSlotView.isHidden = false 
        } else {
            timeSlotHeight.constant = 0
            self.view.layoutIfNeeded()
            costView.isHidden = false
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("Did deselect date \(self.formatter.string(from: date))")
    }
    
    // MARK: - Setup Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7//timeCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let timeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath as IndexPath) as! TimeCollectionViewCell
        
        timeCell.tickImage.isHidden = true
        //timeCell.timeLabel = "
        return timeCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.layer.frame.width/3 - 10,
                      height: collectionView.layer.frame.height/3 - 5)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = collectionView.layer.frame.width - 5
        
        let leftInset = (collectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(leftInset, leftInset, leftInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        costView.isHidden = false
        
        let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
        timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
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
