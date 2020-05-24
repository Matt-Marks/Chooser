//
//  UIFont+Extension.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 5/22/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit

extension UIFont {
    
    enum TondoWeight {
        case light, regular, bold
    }
    
    static func tondo(weight: TondoWeight, size: CGFloat) -> UIFont {
        switch weight {
        case .light:   return UIFont.init(name: "Tondo-Light", size: size)!
        case .regular: return UIFont.init(name: "Tondo-Regular", size: size)!
        case .bold:    return UIFont.init(name: "Tondo-Bold", size: size)!
        }
    }
    
    static func dense(size: CGFloat) -> UIFont {
        return UIFont.init(name: "Dense", size: size)!
    }
    
}

