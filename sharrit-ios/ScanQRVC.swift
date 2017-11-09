//
//  ScanQRVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 8/11/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

class ScanQRVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scanningView: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureMetadataOutput: AVCaptureMetadataOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        let error:NSError? = nil
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as AVCaptureInput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput!.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput!.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            captureMetadataOutput!.rectOfInterest = scanningView.layer.frame
            
            NotificationCenter.default.addObserver(self, selector: #selector(avCaptureInputPortFormatDescriptionDidChangeNotification(notification:)), name:NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
            cameraView.addSubview(qrCodeFrameView!)
            cameraView.bringSubview(toFront: qrCodeFrameView!)
            
            scanningView.layer.borderColor = UIColor.white.cgColor
            scanningView.layer.borderWidth = 1
            
            let lineView = drawLine(fromPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: scanningView.layer.frame.width, y: 0))
            scanningView.addSubview(lineView)
            
            UIView.animate(withDuration: 4, delay: 0, options: [.autoreverse, .repeat], animations: {
                lineView.transform = CGAffineTransform(translationX: 0, y: self.scanningView.layer.frame.height)
            }, completion: nil)
            
        } catch _ {
            print("error: \(error?.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // For full screen
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawLine(fromPoint start: CGPoint, toPoint end: CGPoint) -> UIView {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = UIColor.red.cgColor
        let newUIView = UIView()
        newUIView.layer.addSublayer(line)
        return newUIView
    }
    
    func avCaptureInputPortFormatDescriptionDidChangeNotification(notification: NSNotification) {
        captureMetadataOutput!.rectOfInterest = videoPreviewLayer!.metadataOutputRectOfInterest(for: scanningView.layer.frame)
    }
    
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //print("No QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                //print(metadataObj.stringValue)
                captureSession?.stopRunning()
                
                // Public API Key
                let publicKey: [String: Any] = ["api_key": "UAZPfHqf"]
                
                Alamofire.request(metadataObj.stringValue, method: .post, parameters: publicKey, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                    response in
                    switch response.result {
                    case .success(_):
                        if let data = response.result.value {
                            let sharreData = JSON(data)["content"]
                            
                            var pushData: [Any] = [Any]()
                            pushData.append(sharreData["sharreId"].int!)
                            
                            // Check if Colla exist
                            if (!sharreData["collabAssets"].isEmpty) {
                                pushData.append(sharreData["collabAssets"].array!)
                            }
                            
                            self.performSegue(withIdentifier: "showSharreInfo", sender: pushData)
                        }
                        
                        break
                    case .failure(_):
                        print("QRCode Retrieve Sharre API failed")
                        break
                    }
                }
            }
        }
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func flashlightBtnPressed(_ sender: UIButton) {
        let device:AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == .on) {
                    device.torchMode = .off
                } else {
                    do {
                        try device.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSharreInfo" {
            if let viewSharreVC = segue.destination as? ViewSharreVC, let pushData = sender as? [Any] {
                viewSharreVC.viewSharreFrom = .QRCode
                
                viewSharreVC.sharreID = pushData[0] as! Int
                
                // 2 for collaboration
                if pushData.count == 2 {
                    viewSharreVC.collaborationList = pushData[1] as? [JSON]
                }
            }
        }
    }

}
