//
//  ToolbarButton.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 27/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import Foundation

class SignatureToolbarButton: UICollectionViewCell {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
    
    var imageView :UIImageView?
    
    //==================================================================================================================
    // MARK: Init Methods
    //==================================================================================================================
    
    override init(frame fr: CGRect) {
        super.init(frame: fr)
        backgroundColor = UIColor(red: 16.0/255.0, green: 132.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        layer.cornerRadius = 5.0
        imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 34, height: 34))
        imageView!.contentMode = .scaleAspectFit
        addSubview(imageView!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
