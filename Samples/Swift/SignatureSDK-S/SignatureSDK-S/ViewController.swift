//
//  ViewController.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 21/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import UIKit
import WacomLicensing

/**
*  @brief Simple ENUM for the available colours
*/
enum InkColour {
    case black
    case dark_GREY
    case light_GREY
    case blue
    case red
    case green
    case purple
}

/**
*  @brief Simple enum to track the toolbar buttons
*/
enum ToolbarButton {
    case open
    case capture
    case image
    case save
    case delete
    case settings
    case validate
    case attach
    case about
}

enum FileBrowserMode {
    case open_SIGNATURE //Open saved signature file
    case open_HASH      //Open file for use as binary hash
    case save_SIGNATURE //Save signature file
    case open_IN        //File provided by an 'open in..' action
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, SignatureCaptureDelegate {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
    
    var hashData: Data?
    var currentSignatureObject: SignatureObject?
    var signatureCapture: SignatureCapture?
    
    @IBOutlet var widthField: UITextField!
    @IBOutlet var whoField: UITextField!
    @IBOutlet var whyField: UITextField!
    @IBOutlet var heightField: UITextField!
    @IBOutlet var toolbarCollectionView: UICollectionView!
    
    @IBOutlet var blackButton: UIButton!
    @IBOutlet var darkGreyButton: UIButton!
    @IBOutlet var lightGreyButton: UIButton!
    @IBOutlet var blueButton: UIButton!
    @IBOutlet var redButton: UIButton!
    @IBOutlet var greenButton: UIButton!
    @IBOutlet var purpleButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    fileprivate let colours: [InkColour: UIColor] = [
        .black: UIColor(red: 0.015, green: 0.015, blue: 0.015, alpha: 1.0),
        .dark_GREY:  UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0),
        .light_GREY: UIColor(red: 0.325, green: 0.325, blue: 0.325, alpha: 1.0),
        .blue:       UIColor(red: 0.223, green: 0.270, blue: 0.560, alpha: 1.0),
        .red:        UIColor(red: 0.588, green: 0.156, blue: 0.172, alpha: 1.0),
        .green:      UIColor(red: 0.203, green: 0.478, blue: 0.278, alpha: 1.0),
        .purple:     UIColor(red: 0.419, green: 0.278, blue: 0.454, alpha: 1.0)
    ]
    
    fileprivate let toolbarButtons: [ToolbarButton: UIImage?] = [
        .about:   UIImage(named: "action_about"),
        .open:    UIImage(named: "action_collection"),
        .capture: UIImage(named: "action_edit"),
        .image:   UIImage(named: "action_picture"),
        .save:    UIImage(named: "action_save"),
        .delete:  UIImage(named: "action_discard"),
        .settings:UIImage(named: "action_settings"),
        .validate:UIImage(named: "action_accept"),
        .attach:  UIImage(named: "action_new_attachment")
    ]
    
    fileprivate let checkForWhoAnyWhy = false // Change this to true to add the warning to enter the who / why fields
    
    fileprivate var signatureImageFlags: SIGNATURE_IMAGE_FLAGS = [SIGNATURE_IMAGE_FLAGS.ENCODE_SIGNATURE_DATA, SIGNATURE_IMAGE_FLAGS.TRANSPARENT_BACKGROUND, SIGNATURE_IMAGE_FLAGS.DO_NOT_SCALE]
    
    fileprivate var xPadding :CGFloat = 0.0 //Used for image export
    fileprivate var yPadding :CGFloat = 0.0
    fileprivate var confirmForFileOverwrite = true //By default we want to warn for file overwrites
    
    fileprivate var colourButtons: [UIButton] = []
    
    //==================================================================================================================
    // MARK: UIViewController methods
    //==================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tint our ink selection colours
        let buttonImage = UIImage(named: "colour_button")!
        let selectedImage = UIImage(named: "colour_button_selected")!
        
        blackButton.setImage(buttonImage.tintedImageWithColour(colours[.black]), for: UIControl.State())
        blackButton.setImage(selectedImage.tintedImageWithColour(colours[.black]), for: .selected)
        blackButton.tag = InkColour.black.hashValue
        
        darkGreyButton.setImage(buttonImage.tintedImageWithColour(colours[.dark_GREY]), for: UIControl.State())
        darkGreyButton.setImage(selectedImage.tintedImageWithColour(colours[.dark_GREY]), for: .selected)
        darkGreyButton.tag = InkColour.dark_GREY.hashValue
        
        lightGreyButton.setImage(buttonImage.tintedImageWithColour(colours[.light_GREY]), for: UIControl.State())
        lightGreyButton.setImage(selectedImage.tintedImageWithColour(colours[.light_GREY]), for: .selected)
        lightGreyButton.tag = InkColour.light_GREY.hashValue
        
        blueButton.setImage(buttonImage.tintedImageWithColour(colours[.blue]), for: UIControl.State())
        blueButton.setImage(selectedImage.tintedImageWithColour(colours[.blue]), for: .selected)
        blueButton.tag = InkColour.blue.hashValue
        
        redButton.setImage(buttonImage.tintedImageWithColour(colours[.red]), for: UIControl.State())
        redButton.setImage(selectedImage.tintedImageWithColour(colours[.red]), for: .selected)
        redButton.tag = InkColour.red.hashValue
        
        greenButton.setImage(buttonImage.tintedImageWithColour(colours[.green]), for: UIControl.State())
        greenButton.setImage(selectedImage.tintedImageWithColour(colours[.green]), for: .selected)
        greenButton.tag = InkColour.green.hashValue
        
        purpleButton.setImage(buttonImage.tintedImageWithColour(colours[.purple]), for: UIControl.State())
        purpleButton.setImage(selectedImage.tintedImageWithColour(colours[.purple]), for: .selected)
        purpleButton.tag = InkColour.purple.hashValue
        
        signatureCapture = SignatureCapture(delelgate: self)
        
        /*
        For this example application we will use an SHA-512 hash for the signature key and SHA-1 for any data bound against
        the signature as defaults. This can be changed in the settings screen.
        */
        
        signatureCapture?.keyType  = .SHA_512_HASH  //Used to detect malicious or accidental tampering with the signature object or the data it contains
        signatureCapture?.hashType = .SHA_1_HASH    //Type of hash to use against supplied hash data
        
        //Set our default ink colour to BLUE
        signatureCapture?.inkColor = colours[.blue] //Default to VLUE
        blueButton.isSelected = true
        
        //Create an array of the colour buttons to allow easy deselect later
        colourButtons = [blackButton, darkGreyButton, lightGreyButton, blueButton, redButton, blueButton, greenButton, purpleButton]
        
        
        DispatchQueue.global(qos: .background).async {
            ViewController.seedDocumentDir()
        }
        
        //Reguster class for toolbar items
        toolbarCollectionView.register(SignatureToolbarButton.classForCoder(), forCellWithReuseIdentifier: "TOOLBAT")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Load the license data. This will need to be replaced with a license from http://developer.wacom.com
        
        let licString = "*** YOU WILL NEED A LICENSE FROM DEVELOPER.WACOM.COM"
        do {
            try LicenseValidator.sharedInstance.initLicense(licString)
        } catch let e {
            //There was an error validating the supplied license. Throw an error message
            let av = UIAlertController(title: "License Error", message: e.localizedDescription, preferredStyle: .alert)
            av.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                av.dismiss(animated: true, completion: nil)
            }))
            present(av, animated: true, completion: nil)
        }
        toolbarCollectionView.reloadData()
    }
    
    //==================================================================================================================
    // MARK: Instance Methods
    //==================================================================================================================
    
    /**
    *  @brief Opens a new capture window with the provided who and why data. If the `checkForWhoAndWhy` property is true
    *         then this will display an error dialog if the who or why fields are empty
    */
    func openCaptureWindow() {        
        dismissKeyboard()
        signatureCapture?.openWindow(withSignatory: whoField.text, andReason: whyField.text, boundTo: hashData)
    }
    
    /**
    *  @brief This copies the demo data into the application 'Documents' folder
    */
    class func seedDocumentDir() {
        let sourceDir = Bundle.main.resourceURL
        let targetDir = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as! String)
        let signatureImages = [ "Mondi.sigimg", "Sample.sigimg", "Vincent.sigimg" ]
        let signatureData = [ "Sample-text.txt", "sample-binary.fss" ]
        let sampleDocs = [ "IntuosProSE_en_Manual.pdf", "IntuosSmall_en_Manual.pdf" ]
        let fm = FileManager.default
        
        //Create documents folder if needed
        if !fm.fileExists(atPath: targetDir.appendingPathComponent("Documents").path) {
            do {
                try fm.createDirectory(atPath: targetDir.appendingPathComponent("Documents").path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                
            }
        }
        
        //Copy Sample images
        for img in signatureImages {
            let src = sourceDir!.appendingPathComponent(img)
            let dest = (targetDir as NSURL).appendingPathComponent(img)?.deletingPathExtension().appendingPathComponent("png")
            
            if !fm.fileExists(atPath: dest!.path) {
                do {
                    try fm.copyItem(at: src, to: dest!)
                } catch _ {
                }
            }
            
        }
        
        //Copy sample txt and fss files
        for file in signatureData {
            let src = sourceDir!.appendingPathComponent(file)
            let dest = targetDir.appendingPathComponent(file)
            
            if !fm.fileExists(atPath: dest.path) {
                do {
                    try fm.copyItem(at: src, to: dest)
                } catch _ {
                }
            }
        }
        
        //Copy sample documents
        for document in sampleDocs {
            let src = sourceDir?.appendingPathComponent(document)
            let dest = targetDir.appendingPathComponent("Documents").appendingPathComponent(document)
            
            if !fm.fileExists(atPath: dest.path) {
                do {
                    try fm.copyItem(at: src!, to: dest)
                } catch _ {
                }
            }
            
        }
        
    }
    
    //==================================================================================================================
    // MARK: Signature Import / Export Methods & Utility methods
    //==================================================================================================================
    
    func loadEncodedTXTAtPath(_ path :URL) {
        currentSignatureObject = SignatureObject(base64EncodedSignatureData: try? String(contentsOf:path, encoding: String.Encoding.utf8))
        loadedSigfile(path)
    }
    
    func loadEncodedBINAtPath(_ path :URL) {
        currentSignatureObject = SignatureObject(binarySignatureData: try? Data(contentsOf: path, options: []))
        loadedSigfile(path)
    }
    
    func loadEncodedPNGAtPath(_ path :URL) {
        currentSignatureObject = SignatureObject(encodedImageAtPath: path.path)
        loadedSigfile(path)
    }
    
    func loadedSigfile(_ path :URL) {
        if currentSignatureObject == nil {
            UIAlertView(title: "Error", message: "Failed to load encoded signature data from file: \(path.lastPathComponent)", delegate: nil, cancelButtonTitle: "OK").show()
        }
        toolbarCollectionView.reloadData()
    }
    
    func exportCurrentSingature(_ path: URL) { //Only support PNG for the moment
        //Fix output extension
        let output = path.deletingPathExtension().appendingPathExtension("png")
        let w = Int(widthField.text!)
        let h = Int(heightField.text!)
        
        if let sigObj = currentSignatureObject {
            if (w != nil) && (h != nil) {
                sigObj.writeSignature(toPNG: output.path, with: signatureImageFlags, width: UInt(w!), height: UInt(h!), paddingX: xPadding, paddingY: yPadding, inkColor: signatureCapture?.inkColor, backgroundColor: UIColor.white)
            }
        }
    }
    
    //==================================================================================================================
    // MARK: Action callbacks
    //==================================================================================================================
    
    /**
    *  @brief Dismisses the keyboad if it is currently being displayed
    */
    @IBAction func dismissKeyboard() {
        whyField.resignFirstResponder()
        whoField.resignFirstResponder()
        widthField.resignFirstResponder()
        heightField.resignFirstResponder()
    }
    
    /**
    *  @brief Action callback when one of the buttons are tapped
    *
    *  @param sender The button that has been tapped
    */
    @IBAction func colourButtonSelected(_ sender: UIButton) {
        
        //Deselect the current button
        for button in colourButtons {
            if button.isSelected {
                button.isSelected = false
                break
            }
        }
        
        //Set the ink colour
        for colour in colours.keys {
            if colour.hashValue == sender.tag {
                signatureCapture?.inkColor = colours[colour]
                break
            }
        }
        
        //Select the new colour button
        
        sender.isSelected = true
    }
    
    //==================================================================================================================
    // MARK: Storyboard methods / navigation callbacks
    //==================================================================================================================
    
    @IBAction func unwindToMainViewController(_ unwindSegue: UIStoryboardSegue!) {
        //Do nothing
    }
    
    @IBAction func unwindWithNewSettings(_ unwindSegue: UIStoryboardSegue!) {
        let sc = unwindSegue.source as! CaptureSettingsController
        xPadding = sc.xPadding
        yPadding = sc.yPadding
        signatureImageFlags = sc.imageFlags!
        
        if let sigc = signatureCapture {
            sigc.keyType = sc.signatureHashType
            sigc.hashType = sc.extraDataHashType
            sigc.md5_MacKeyValue = sc.macKey
        }
        
        if let so = currentSignatureObject {
            so.keyValue = sc.macKey
        }
    }
    
    @IBAction func unwindWithFileOpen(_ unwindSegue: UIStoryboardSegue!) {
        let fileBrowser = unwindSegue.source as! FileBrowser
        
        switch fileBrowser.view.tag {
        case FileBrowserMode.open_SIGNATURE.hashValue:
            if fileBrowser.selectedFilename == nil {
                UIAlertView(title: "Error", message: "No File Selected", delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            
            currentSignatureObject = nil
            
            switch fileBrowser.selectedFilename!.pathExtension.lowercased() {
            case "txt":
                loadEncodedTXTAtPath(fileBrowser.selectedFilename! as URL)
            case "fss":
                loadEncodedBINAtPath(fileBrowser.selectedFilename! as URL)
            case "png":
                loadEncodedPNGAtPath(fileBrowser.selectedFilename! as URL)
            default:
                UIAlertView(title: "Error", message: "Unsupported file type: \(fileBrowser.selectedFilename!.pathExtension.lowercased())", delegate: nil, cancelButtonTitle: "OK").show()
                toolbarCollectionView.reloadData()
                return
            }
        case FileBrowserMode.open_HASH.hashValue:
            if fileBrowser.selectedFilename == nil {
                UIAlertView(title: "Error", message: "No File Selected", delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            
            hashData = try? Data(contentsOf: fileBrowser.selectedFilename! as URL)
            toolbarCollectionView.reloadData()
        case FileBrowserMode.open_IN.hashValue:
            if fileBrowser.selectedFilename == nil {
                return
            }
            
            if(confirmForFileOverwrite && FileManager.default.fileExists(atPath: fileBrowser.selectedFilename!.path)) {
                let av = UIAlertController(title: "Overwrite File?", message: "Are you sure you want to overwrite \(fileBrowser.selectedFilename!)?", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                    do {
                        try FileManager.default.removeItem(at: fileBrowser.selectedFilename! as URL)
                    } catch _ {
                    }
                    do {
                        try FileManager.default.moveItem(at: fileBrowser.sourceFile! as URL, to: fileBrowser.selectedFilename! as URL)
                    } catch _ {
                    }
                    UIAlertView(title: nil, message: "Wrote: \(fileBrowser.selectedFilename!.lastPathComponent)", delegate: nil, cancelButtonTitle: "OK").show()
                }))
                av.addAction(UIAlertAction(title: "No", style: .cancel, handler:nil))
                dismiss(animated: false, completion: nil)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.present(av, animated: true, completion: nil)
                })
            } else {
                do {
                    try FileManager.default.removeItem(at: fileBrowser.selectedFilename! as URL)
                } catch _ {
                }
                do {
                    try FileManager.default.moveItem(at: fileBrowser.sourceFile! as URL, to: fileBrowser.selectedFilename! as URL)
                } catch _ {
                }
                UIAlertView(title: nil, message: "Wrote: \(fileBrowser.selectedFilename!.lastPathComponent)", delegate: nil, cancelButtonTitle: "OK").show()
            }
        case FileBrowserMode.save_SIGNATURE.hashValue:
            if fileBrowser.selectedFilename == nil {
                UIAlertView(title: "Error", message: "No File Selected", delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            
            if(confirmForFileOverwrite && FileManager.default.fileExists(atPath: fileBrowser.selectedFilename!.path)) {
                let av = UIAlertController(title: "Overwrite File?", message: "Are you sure you want to overwrite \(fileBrowser.selectedFilename!)?", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                    self.exportCurrentSingature(fileBrowser.selectedFilename! as URL)
                }))
                av.addAction(UIAlertAction(title: "No", style: .cancel, handler:nil))
                dismiss(animated: false, completion: nil)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.present(av, animated: true, completion: nil)
                })
            } else {
                exportCurrentSingature(fileBrowser.selectedFilename! as URL)
            }
            
        default:
            NSLog("Unknown File Mode: \(fileBrowser.view.tag)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let target = segue.identifier {
            switch target {
            case "About":       //About Screen
                let dest = segue.destination as! AboutScreen
                dest.versionString = signatureCapture?.versionString()
            case "ShowImage":  //Show signature Image Screen
                let dest = segue.destination as! SignatureImageController
                let width = UInt(Int(widthField.text!)!)
                let height = UInt(Int(heightField.text!)!)
                let img = currentSignatureObject!.signatureAsUIImage(with: signatureImageFlags,
                    width: width,
                    height: height,
                    paddingX: xPadding,
                    paddingY: yPadding,
                    inkColor: signatureCapture?.inkColor,
                    backgroundColor: UIColor.white)
                dest.signatureImage = img
                activityIndicator.stopAnimating()
            case "OpenFile":  //Open File
                let dest = segue.destination as! FileBrowser
                dest.view.tag = FileBrowserMode.open_SIGNATURE.hashValue
                dest.titleText = "Select a signature file to open:"
                dest.isOpenDialog = true
                dest.signatureTypesOnly = true
                dest.baseDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String)
            case "SaveFile":  //Save PNG of signature
                let dest = segue.destination as! FileBrowser
                dest.view.tag = FileBrowserMode.save_SIGNATURE.hashValue
                dest.titleText = "Enter filename or select a file to overwrite:"
                dest.baseDirectory = URL(fileURLWithPath:  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String)
                dest.isOpenDialog = false
                dest.signatureTypesOnly = true
            case "HashFile":
                let dest = segue.destination as! FileBrowser
                dest.titleText = "Select a file to use as a hash:"
                dest.baseDirectory = URL(fileURLWithPath:  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String)
                dest.isOpenDialog = false
                dest.signatureTypesOnly = false
                dest.view.tag = FileBrowserMode.open_HASH.hashValue
            case "VerifySignature":
                let dest = segue.destination as! SignatureIntegrityController
                dest.sigObj = currentSignatureObject
                dest.hashData = hashData
            case "CaptureSettings":
                let dest = segue.destination as! CaptureSettingsController
                dest.xPadding = xPadding
                dest.yPadding = yPadding
                dest.imageFlags = signatureImageFlags
                
                if let sigc = signatureCapture {
                    dest.signatureHashType = sigc.keyType
                    dest.extraDataHashType = sigc.hashType
                }
                dest.macKey = currentSignatureObject?.keyValue
                
            default:
                print("Warining: Unknown Segue \(String(describing: segue.identifier))")
            }
        }
    }
    
    //==================================================================================================================
    // MARK: SignatureCapture delegate methods
    //==================================================================================================================
    
    func signatureCapture(_ captureView: SignatureCapture!, completedWithSignature signature: SignatureObject!) {
        currentSignatureObject = signature
        currentSignatureObject?.addExtraDataItem(withKey: "DATA1", andValue: "Some extra data from SWIFT demo")
        toolbarCollectionView.reloadData()
    }
    
    func signatureCapture(_ captureView: SignatureCapture!, cancelledWith reason: SIGNATURE_CANCEL_REASON) {
        var reasonText = "Unknown reason"
        
        switch reason {
            
        case .USER_CANCELLED:
            reasonText = "The user cancelled the capture session"
            
        case .NO_SIGNATURE_DATA_CAPTURED:
            reasonText = "No signature data was captured during the session"
            
        case .CAPTURE_ABORTED:
            reasonText = "The signature capture was aboerted, check console for error logs"
            
        }
        
        UIAlertView(title: "Capture Cancelled", message: reasonText, delegate: nil, cancelButtonTitle: "OK").show()
        currentSignatureObject = nil
        toolbarCollectionView.reloadData()
    }
    
    //==================================================================================================================
    // MARK: UICollectionView delegate methods
    //==================================================================================================================
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let button :SignatureToolbarButton = collectionView.dequeueReusableCell(withReuseIdentifier: "TOOLBAT", for: indexPath) as! SignatureToolbarButton
        
        button.tag = indexPath.row
        
        for tb in toolbarButtons.keys {
            if(tb.hashValue == indexPath.row.hashValue) {
                if currentSignatureObject == nil && ((tb == .image) || (tb == .save) || (tb == .delete) || (tb == .validate)) {
                    button.imageView?.image = toolbarButtons[tb]??.tintedImageWithColour(colours[.light_GREY])
                    button.isUserInteractionEnabled = false
                } else {
                    button.imageView?.image = toolbarButtons[tb]!
                    button.isUserInteractionEnabled = true
                }
                break
            }
        }
        
        return button
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolbarButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissKeyboard()
        
        for tb in toolbarButtons.keys {
            if(tb.hashValue == indexPath.row.hashValue) {
                switch tb {
                case .capture:
                    openCaptureWindow()
                case .about:
                    performSegue(withIdentifier: "About", sender: nil)
                case .delete:
                    //Clear out local signature object & reset input fields
                    currentSignatureObject = nil
                    whoField.text = ""
                    whyField.text = ""
                    hashData = nil
                    widthField.text = "600"
                    heightField.text = "600"
                    toolbarCollectionView.reloadData()
                case .image:
                    //Check the width and height field
                    if Int(heightField.text!) == nil {
                        UIAlertView(title: "Error", message: "Image height must be set", delegate: nil, cancelButtonTitle: "OK").show()
                    } else if Int(widthField.text!) == nil {
                        UIAlertView(title: "Error", message: "Image width must be set", delegate: nil, cancelButtonTitle: "OK").show()
                    } else {
                        activityIndicator.startAnimating()
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.performSegue(withIdentifier: "ShowImage", sender: nil)
                        })
                    }
                case .open:
                    performSegue(withIdentifier: "OpenFile", sender: nil)
                case .save:
                    if Int(heightField.text!) == nil {
                        UIAlertView(title: "Error", message: "Image height must be set", delegate: nil, cancelButtonTitle: "OK").show()
                    } else if Int(widthField.text!) == nil {
                        UIAlertView(title: "Error", message: "Image width must be set", delegate: nil, cancelButtonTitle: "OK").show()
                    } else {
                        performSegue(withIdentifier: "SaveFile", sender: nil)
                    }
                case .attach:
                    performSegue(withIdentifier: "HashFile", sender: nil)
                case .validate:
                    performSegue(withIdentifier: "VerifySignature", sender: nil)
                case .settings:
                    performSegue(withIdentifier: "CaptureSettings", sender: nil)
                }
            }
        }
    }
    
    //==================================================================================================================
    // MARK: UITextField delegate methods
    //==================================================================================================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return(true)
    }
    
}


