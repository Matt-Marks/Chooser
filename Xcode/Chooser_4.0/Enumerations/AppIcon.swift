//
//  AppIcon.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 5/27/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation
import UIKit

enum AppIcon: Int, CaseIterable {
    
    case Neon
    case Lithium
    case Helium
    case Oxygen
    case Barium
    case Chlorine
    case Phosphorus
    case Silicon
    case Zinc
    case Black
    
    var name: String {
        switch self {
        case .Neon:       return "Neon"
        case .Lithium:    return "Lithium"
        case .Helium:     return "Helium"
        case .Oxygen:     return "Oxygen"
        case .Barium:     return "Barium"
        case .Chlorine:   return "Chlorine"
        case .Phosphorus: return "Phosphorus"
        case .Silicon:    return "Silicon"
        case .Zinc:       return "Zinc"
        case .Black:      return "Black"
        }
    }
    
    var colors: [UIColor] {
        switch self {
        case .Neon:       return [.neon, .lithium]
        case .Lithium:    return [.lithium, .helium]
        case .Helium:     return [.helium, .oxygen]
        case .Oxygen:     return [.oxygen, .iron]
        case .Barium:     return [.barium, .chlorine]
        case .Chlorine:   return [.chlorine, .phosphorus]
        case .Phosphorus: return [.phosphorus, .silicon]
        case .Silicon:    return [.silicon, .zinc]
        case .Zinc:       return [.zinc, .nitrogen]
        case .Black:      return [.black, .black]
        }
    }
    
}
