//
//  UIImage+TintImage.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 21/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import UIKit

extension UIImage {
    func tintedImageWithColour(_ tintColour: UIColor!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
    
        context?.setBlendMode(CGBlendMode.normal)
        context?.draw(self.cgImage!, in: rect)
        context?.setBlendMode(CGBlendMode.sourceIn)
        tintColour.setFill()
        context?.fill(rect)
        
        let rv = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return(rv)!
    }
}


