//
//  SoundEffect.swift
//  Chooser_4.0
//
//  Created by Matthew Marks on 8/13/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation

enum SoundEffect: CaseIterable {
    
    case Pop1
    case Pop2
    case Pop3
    case Pop4
    case Pop5
    case Pop6
    case Swoosh1
    case Swoosh2
    case Swoosh3
    case Swoosh4
    case Swoosh5
    case Swoosh6
    case Winner
    
    var resourceName: String {
        switch self {
        case .Pop1: return "Pop1"
        case .Pop2: return "Pop2"
        case .Pop3: return "Pop3"
        case .Pop4: return "Pop4"
        case .Pop5: return "Pop5"
        case .Pop6: return "Pop6"
        case .Swoosh1: return "Swoosh1"
        case .Swoosh2: return "Swoosh2"
        case .Swoosh3: return "Swoosh3"
        case .Swoosh4: return "Swoosh4"
        case .Swoosh5: return "Swoosh5"
        case .Swoosh6: return "Swoosh6"
        case .Winner: return "Winner"
        }
    }
}
