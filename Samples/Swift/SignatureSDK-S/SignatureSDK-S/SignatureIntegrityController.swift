//
//  SignatureIntegrityController.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 28/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import UIKit

class SignatureIntegrityController: UIViewController, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
    
    var sigObj :SignatureObject?
    var hashData :Data?
    
    @IBOutlet fileprivate var okButton :UIButton!
    @IBOutlet fileprivate var who :UILabel!
    @IBOutlet fileprivate var when :UILabel!
    @IBOutlet fileprivate var why :UILabel!
    @IBOutlet fileprivate var captureArea :UILabel!
    @IBOutlet fileprivate var signatureArea :UILabel!
    @IBOutlet fileprivate var digitizer :UILabel!
    @IBOutlet fileprivate var driver :UILabel!
    @IBOutlet fileprivate var machineOS :UILabel!
    @IBOutlet fileprivate var hashType :UILabel!
    @IBOutlet fileprivate var integrityStatus :UILabel!
    @IBOutlet fileprivate var documentHashType :UILabel!
    @IBOutlet fileprivate var documentHashStatus :UILabel!
    @IBOutlet fileprivate var extraItemsLabel :UILabel!
    @IBOutlet fileprivate var extraItemsButton :UIButton!
    @IBOutlet fileprivate var integView :UIView!
    
    fileprivate var extraDataPopoverController :UIPopoverController?
    
    //==================================================================================================================
    // MARK: UIViewController Methods
    //==================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.layer.cornerRadius = 5.0
        extraItemsButton.setImage(UIImage(named: "action_about")?.tintedImageWithColour(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)), for: UIControl.State())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sig = sigObj {
            who.text = sig.who
            why.text = sig.why
            let bounds = "\(Int(sig.captureAreaBounds.width))x\(Int(sig.captureAreaBounds.height))"
            print(bounds)
            when.text = DateFormatter.localizedString(from: sig.when, dateStyle: .short, timeStyle: .short)
            captureArea.text =  "\(Int(sig.captureAreaBounds.width))x\(Int(sig.captureAreaBounds.height))"
            signatureArea.text =  "\(Int(sig.signatureAreaBounds.width))x\(Int(sig.signatureAreaBounds.height))"
            digitizer.text = sig.additionalData[kCaptureDigitizer]! as? String
            driver.text = sig.additionalData[kCaptureDigitizerDriver]! as? String
            machineOS.text = sig.additionalData[kCaptureMachineOS]! as? String
            hashType.text = SignatureIntegrityController.stringForHashType(getHashTypeForSigObj())
            integrityStatus.text = validationStringForSignature()
            documentHashType.text = SignatureIntegrityController.stringForHashType(getDocHashTypeForSigObj())
            documentHashStatus.text = validationStringForDocumentData()
            
            if sig.extraDataItems().count > 0 {
                extraItemsLabel.text = "\(sig.extraDataItems().count) Extra Data Items:"
            } else {
                extraItemsLabel.isHidden = true
                extraItemsButton.isHidden = true
            }
        }
    }
    
    //==================================================================================================================
    // MARK: Instance Methods
    //==================================================================================================================
    
    class func stringForHashType(_ hashType :SIGNATURE_HASH_TYPE) -> String {
        switch hashType {
        case .MD5_HASH:
            return "MD5"
        case .MD5_MAC_HASH:
            return "MD5 with MAC-KEY"
        case .SHA_1_HASH:
            return "SHA-1"
        case .SHA_224_HASH:
            return "SHA-224"
        case .SHA_256_HASH:
            return "SHA-256"
        case .SHA_384_HASH:
            return "SHA-384"
        case .SHA_512_HASH:
            return "SHA-512"
        case .NO_HASH:
            return "No Hash"
        }
    }
    
    func getHashTypeForSigObj() -> SIGNATURE_HASH_TYPE {
        var rv = SIGNATURE_HASH_TYPE.NO_HASH

        if let sig = sigObj {
            let status :SIGNATURE_INTEGRITY_STATUS = sig.checkIntegrity(.MD5_HASH)
            
            switch status {
            case .INTEGRITY_MISSING:
                rv = .NO_HASH
            case .INTEGRITY_OK, .INTEGRITY_FAIL, .INTEGRITY_INVALID_KEY, .INTEGRITY_WRONG_TYPE:
                rv = .MD5_HASH
            }
            
            let hashTypes :[SIGNATURE_HASH_TYPE] = [ .SHA_1_HASH, .SHA_224_HASH, .SHA_256_HASH, .SHA_384_HASH, .SHA_512_HASH, .MD5_MAC_HASH ]
          
            for shaType in hashTypes {
                if(sig.checkIntegrity(shaType) != SIGNATURE_INTEGRITY_STATUS.INTEGRITY_WRONG_TYPE) {
                    return shaType
                }
            }
            
        }
        
        return rv
    }
    
    func validationStringForSignature() -> String {
        let hash = getHashTypeForSigObj()
        
        if hash == .NO_HASH {
            return "No Hash"
        }
    
        if let sig = sigObj {
            switch sig.checkIntegrity(hash) {
            case .INTEGRITY_FAIL:
                return "Integrity failed"
            case .INTEGRITY_INVALID_KEY:
                return "Invalid MAC key"
            case .INTEGRITY_MISSING:
                return "No integrity data found"
            case .INTEGRITY_OK:
                return "Integrity OK"
            case .INTEGRITY_WRONG_TYPE:
                return "Integrity is of wrong type"
            }
        }
        return "No Hash"
    }
    
    func getDocHashTypeForSigObj() -> SIGNATURE_HASH_TYPE {
        let data = hashData
        
        if(data == nil) {
            return .NO_HASH
        }
        
        if let sig = sigObj {
            let status = sig.checkSignatureData(.MD5_HASH, with: data)
            
            if (status == SIGNATURE_SIGNED_DATA_STATUS.DATA_NO_DATA) || (status == SIGNATURE_SIGNED_DATA_STATUS.DATA_NO_HASH) {
                return .NO_HASH
            }
            
            let hashTypes :[SIGNATURE_HASH_TYPE] = [ .SHA_1_HASH, .SHA_224_HASH, .SHA_256_HASH, .SHA_384_HASH, .SHA_512_HASH, .MD5_MAC_HASH ]

            for type in hashTypes {
                if sig.checkSignatureData(type, with: data) != .DATA_BAD_TYPE {
                    return type
                }
            }
        }
        
        return SIGNATURE_HASH_TYPE.NO_HASH
    }
    
    func validationStringForDocumentData() -> String {
        let hash = getDocHashTypeForSigObj()
        
        if hash == .NO_HASH {
            return "No Hash"
        }
        
        if let sig = sigObj {
            switch sig.checkSignatureData(hash, with: hashData) {
            case .DATA_BAD_HASH:
                return "Data hash does not match. Document differs."
            case .DATA_BAD_TYPE:
                return "Incorrect hash type."
            case .DATA_GOOD:
                return "Data hash matches. Document is the same."
            case .DATA_NO_DATA:
                return "No hash data provided"
            case .DATA_NO_HASH:
                return "No document hash data defined"
            }
        }
        
        return "No Hash"
    }
    
    //==================================================================================================================
    // MARK: Action Callback Methods
    //==================================================================================================================
    
    @IBAction func extraItemsButtonTapped(_ sender: AnyObject) {
        let vc = UITableViewController(style: .plain)
        let ct :CGFloat = CGFloat(sigObj!.extraDataItems().count)
        
        vc.tableView.delegate = self
        vc.tableView.dataSource = self
        vc.tableView.rowHeight = 33.0
        vc.preferredContentSize = CGSize(width: 500.0, height: 33.0 * ct)
        
        extraDataPopoverController = UIPopoverController(contentViewController: vc)
        extraDataPopoverController?.present(from: extraItemsButton.frame, in: integView, permittedArrowDirections: .any, animated: true)
    }
    
    //==================================================================================================================
    // MARK: UIPopoverController delegate methods
    //==================================================================================================================

    func popoverController(_ popoverController: UIPopoverController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        popoverController.dismiss(animated: true)
        extraDataPopoverController = nil
    }
    
    //==================================================================================================================
    // MARK: UITableView delegate methods
    //==================================================================================================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sig = sigObj {
            return sig.extraDataItems().count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "extradata") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "extradata")
            cell?.textLabel!.font = UIFont(name: "Helvetica", size: 16)
            cell?.textLabel!.textColor = UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.0)
            cell?.detailTextLabel?.font =  UIFont(name: "Helvetica", size: 16)
            cell?.detailTextLabel?.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        
        if let sig = sigObj {
            var dict = sig.extraDataItems() as! [String: String]
            let key = Array(sig.extraDataItems().keys)[indexPath.row] as! String
            cell?.textLabel!.text = key
            cell?.detailTextLabel?.text = dict[key]
        }
        
        return cell!
    }
}
