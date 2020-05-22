//
//  CaptureSettingsController.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 28/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import UIKit

class CaptureSettingsController: UIViewController, UITextFieldDelegate, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
  
    var xPadding :CGFloat = 0.0
    var yPadding :CGFloat = 0.0
    var macKey :String?
    var imageFlags :SIGNATURE_IMAGE_FLAGS?
    var signatureHashType :SIGNATURE_HASH_TYPE = .NO_HASH
    var extraDataHashType :SIGNATURE_HASH_TYPE = .NO_HASH
    
    fileprivate var settingsPopover :UIPopoverController?
    fileprivate var currentPopoverIsDocumentKeyType :Bool = false
    fileprivate let types :[SIGNATURE_HASH_TYPE] = [ .NO_HASH, .SHA_1_HASH, .SHA_224_HASH, .SHA_256_HASH, .SHA_384_HASH, .SHA_512_HASH, .MD5_HASH, .MD5_MAC_HASH ]
   
    //NS_OPTIONS conversion isn't quite there yet
    fileprivate let encodeFlag :UInt8      = 1 << 0
    fileprivate let watermarkFlag :UInt8   = 1 << 1
    fileprivate let transparentFlag :UInt8 = 1 << 2
    fileprivate let clipFlag :UInt8        = 1 << 3
    fileprivate let dontScaleFlag :UInt8   = 1 << 4

    @IBOutlet fileprivate var cancelButton :UIButton!
    @IBOutlet fileprivate var okButton :UIButton!
    @IBOutlet fileprivate var signtureKeyButton :UIButton!
    @IBOutlet fileprivate var documentKeyButton :UIButton!
    @IBOutlet fileprivate var signatureKeyType :UILabel!
    @IBOutlet fileprivate var documentKeyType :UILabel!
    @IBOutlet fileprivate var md5MacLabel :UILabel!
    @IBOutlet fileprivate var encodeSignatureSwitch :UISwitch!
    @IBOutlet fileprivate var renderWatermark :UISwitch!
    @IBOutlet fileprivate var transparentBackground :UISwitch!
    @IBOutlet fileprivate var clipToBounds :UISwitch!
    @IBOutlet fileprivate var scaleOutput :UISwitch!
    @IBOutlet fileprivate var xPaddingField :UITextField!
    @IBOutlet fileprivate var yPaddingField :UITextField!
    @IBOutlet fileprivate var md5MACKeyField :UITextField!
    
    //==================================================================================================================
    // MARK: UIViewController methods vars
    //==================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.layer.cornerRadius = 5.0
        cancelButton.layer.cornerRadius = 5.0
        documentKeyButton.setImage(UIImage(named: "action_edit")?.tintedImageWithColour(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)), for: UIControl.State())
        signtureKeyButton.setImage(UIImage(named: "action_edit")?.tintedImageWithColour(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)), for: UIControl.State())
        updateFields()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        dismissKeyboard()
        updateTextData()
        updateImageFlags()
    }
    //==================================================================================================================
    // MARK: Instance methods
    //==================================================================================================================
    
    func updateFields() {
        signatureKeyType.text = SignatureIntegrityController.stringForHashType(signatureHashType)
        documentKeyType.text = SignatureIntegrityController.stringForHashType(extraDataHashType)
        md5MACKeyField.text = macKey
        
        if signatureHashType == .MD5_MAC_HASH {
            md5MACKeyField.isHidden = false
            md5MacLabel.isHidden = false
        } else {
            md5MACKeyField.isHidden = true
            md5MacLabel.isHidden = true
        }
        
        if let i_flags = imageFlags?.rawValue {
            let flags = UInt8(i_flags)
            encodeSignatureSwitch.isOn =  flags & encodeFlag > 0
            renderWatermark.isOn = flags & watermarkFlag > 0
            transparentBackground.isOn = flags & transparentFlag > 0
            clipToBounds.isOn = flags & clipFlag > 0
            scaleOutput.isOn = flags & dontScaleFlag > 0
        }
      
        xPaddingField.text = "\(xPadding)"
        yPaddingField.text = "\(yPadding)"

    }

    func dismissKeyboard() {
        md5MACKeyField.resignFirstResponder()
        xPaddingField.resignFirstResponder()
        yPaddingField.resignFirstResponder()
    }
    
    func updateTextData() {
        macKey = self.md5MACKeyField.text;
        xPadding = CGFloat(NSString(string: xPaddingField.text!).floatValue)
        yPadding = CGFloat(NSString(string: yPaddingField.text!).floatValue)
    }
    
    //==================================================================================================================
    // MARK: Action Callbacks
    //==================================================================================================================

    @IBAction func updateImageFlags() {
        dismissKeyboard()
        
        if let _ = imageFlags?.rawValue {
            var flags = UInt8(0)
            
            if encodeSignatureSwitch.isOn {
                flags |= encodeFlag
            }
            
            if renderWatermark.isOn {
                flags |= watermarkFlag
            }

            if transparentBackground.isOn {
                flags |= transparentFlag
            }

            if clipToBounds.isOn {
                flags |= clipFlag
            }

            if scaleOutput.isOn {
                flags |= dontScaleFlag
            }
            
            imageFlags = SIGNATURE_IMAGE_FLAGS(rawValue: UInt(flags))
        }

    }
    
    @IBAction func documentKeyButtonAction(_ sender: UIButton!) {
        let tb = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 231), style: .plain) as UITableView
        tb.delegate = self
        tb.dataSource = self
        tb.rowHeight = 33
        let vc = UIViewController()
        vc.view = tb
        vc.preferredContentSize = CGSize(width: 200, height: 231)
        
        currentPopoverIsDocumentKeyType = true
        settingsPopover = UIPopoverController(contentViewController: vc)
        settingsPopover?.delegate = self
        settingsPopover?.present(from: sender.frame, in: sender.superview!, permittedArrowDirections: .any, animated: true)
    }
    
    @IBAction func signatureKeyButtonAction(_ sender: UIButton!) {
        let tb = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 264), style: .plain) as UITableView
        tb.delegate = self
        tb.dataSource = self
        tb.rowHeight = 33
        let vc = UIViewController()
        vc.view = tb
        vc.preferredContentSize = CGSize(width: 200, height: 264)
        
        currentPopoverIsDocumentKeyType = false
        settingsPopover = UIPopoverController(contentViewController: vc)
        settingsPopover?.delegate = self
        settingsPopover?.present(from: sender.frame, in: sender.superview!, permittedArrowDirections: .any, animated: true)
    }
    
    //==================================================================================================================
    // MARK: UITextField delegate methods
    //==================================================================================================================

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
        updateTextData()
    }
    
    //==================================================================================================================
    // MARK: UIPopover delegate methods
    //==================================================================================================================

    func popoverController(_ popoverController: UIPopoverController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        let button = currentPopoverIsDocumentKeyType ? signtureKeyButton : documentKeyButton
        popoverController.present(from: (button?.frame)!, in: self.view, permittedArrowDirections: .any, animated: false)
    }
    
    //==================================================================================================================
    // MARK: UITableView delegate methods
    //==================================================================================================================

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "popovercell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "popovercell")
            cell?.textLabel!.font = UIFont(name: "Helvetica", size: 16)
            cell?.textLabel!.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
        
        let currentlySelected :SIGNATURE_HASH_TYPE = currentPopoverIsDocumentKeyType ? extraDataHashType : signatureHashType
        
        cell?.textLabel!.text = SignatureIntegrityController.stringForHashType(types[indexPath.row])
        
        if currentlySelected == types[indexPath.row] {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentPopoverIsDocumentKeyType {
            return 7
        } else {
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentPopoverIsDocumentKeyType {
            extraDataHashType = types[indexPath.row]
        } else {
            signatureHashType = types[indexPath.row]
        }
        settingsPopover?.dismiss(animated: true)
        settingsPopover = nil
        updateFields()
    }
}
