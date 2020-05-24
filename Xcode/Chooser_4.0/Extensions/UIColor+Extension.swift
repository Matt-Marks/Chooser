//
//  UIColor+Extension.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 2/11/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    public convenience init(hexVal: Int) {
        let red   = CGFloat((hexVal >> 16) & 0xFF)/255.0
        let green = CGFloat((hexVal >> 8) & 0xFF)/255.0
        let blue  = CGFloat((hexVal >> 0) & 0xFF)/255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var hexVal: Int {
        var red: CGFloat   = 0
        var green: CGFloat = 0
        var blue: CGFloat  = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
    }
    
    static var neon       = UIColor.init(hexVal: 0xE52C61)
    static var lithium    = UIColor.init(hexVal: 0xF34C49)
    static var helium     = UIColor.init(hexVal: 0xFF6E31)
    static var oxygen     = UIColor.init(hexVal: 0xFF9D31)
    static var iron       = UIColor.init(hexVal: 0xFFCD31)
    static var barium     = UIColor.init(hexVal: 0x81C652)
    static var chlorine   = UIColor.init(hexVal: 0x03C074)
    static var phosphorus = UIColor.init(hexVal: 0x1BA19D)
    static var silicon    = UIColor.init(hexVal: 0x3182C5)
    static var zinc       = UIColor.init(hexVal: 0x586CB8)
    static var nitrogen   = UIColor.init(hexVal: 0x7E55AB)
    
}
