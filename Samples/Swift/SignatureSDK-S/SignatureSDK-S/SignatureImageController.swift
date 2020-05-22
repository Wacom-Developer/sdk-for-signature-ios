//
//  SignatureImageController.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 21/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import UIKit

class SignatureImageController: UIViewController {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
    
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var signatureView: UIImageView!
   
    var signatureImage: UIImage?
 
    //==================================================================================================================
    // MARK: UIViewController methods
    //==================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoImage.image = UIImage(named: "logo_window")?.tintedImageWithColour(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview?.bounds = CGRect(x: 0, y: 0, width: 520.0, height: 376.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.signatureView.image = self.signatureImage
    }
}
