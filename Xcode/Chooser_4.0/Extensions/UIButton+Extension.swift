//
//  UIButton+Extension.swift
//  Chooser_4.0
//
//  Created by Matthew Marks on 7/25/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func clearColorForTitle() {
        
        let buttonSize = bounds.size
        
        if let font = titleLabel?.font{
            let attribs = [NSAttributedString.Key.font: font]
            
            if let textSize = titleLabel?.text?.size(withAttributes: attribs) {
                UIGraphicsBeginImageContextWithOptions(buttonSize, false, UIScreen.main.scale)
                
                if let ctx = UIGraphicsGetCurrentContext(){
                    ctx.setFillColor(UIColor.white.cgColor)
                    
                    let center = CGPoint(x: buttonSize.width / 2 - textSize.width / 2, y: buttonSize.height / 2 - textSize.height / 2)
                    let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
                    ctx.addPath(path.cgPath)
                    ctx.fillPath()
                    ctx.setBlendMode(.destinationOut)
                    
                    titleLabel?.text?.draw(at: center, withAttributes: [NSAttributedString.Key.font: font])
                    
                    
                    if let viewImage = UIGraphicsGetImageFromCurrentImageContext(){
                        UIGraphicsEndImageContext()
                        
                        let maskLayer = CALayer()
                        maskLayer.contents = ((viewImage.cgImage) as AnyObject)
                        maskLayer.frame = bounds
                        
                        layer.mask = maskLayer
                    }
                }
            }
        }
    }
    
}
