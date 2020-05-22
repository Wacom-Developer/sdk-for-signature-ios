//
//  AboutScreen.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 21/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import UIKit

class AboutScreen : UIViewController {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
    var versionString: String?
    var licenseString: String?
    
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var versionText: UILabel!
    @IBOutlet var licenseText: UILabel!
    
    //==================================================================================================================
    // MARK: UIViewController methods
    //==================================================================================================================
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set the SDK version string
        if let vertext = self.versionString {
            self.versionText.text = "Version " + vertext
        } else {
            self.versionText.text = "Unable to retreive version information"
        }
        
        //Set the license string
        if let licText = self.licenseString {
            self.licenseText.text = licText
        } else {
            self.licenseText.text = ""
        }
        
        //Tint the logo
        self.logoImage.image = UIImage(named: "logo_sdk_screen")?.tintedImageWithColour(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0))
    }
    
    //==================================================================================================================
    // MARK: Instance methods
    //==================================================================================================================
    
    @IBAction func goToWebsite(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string:"http://www.wacom.com/")!)
    }
    
    
}
