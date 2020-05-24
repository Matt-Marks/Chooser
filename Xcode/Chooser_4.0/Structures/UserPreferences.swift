//
//  UserPreferences.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 2/11/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation
import UIKit

struct UserPreferences {
    
    private enum Keys {
        static let sounds             = "SOUNDS"
        static let vibrations         = "VIBRATIONS"
        static let backgroundGradient = "BACKGROUNDGRADIENT"
        static let numberOfWinners    = "NUMBEROFWINNERS"
    }
        
    public static var sounds: Bool {
        get {
            return keyExists(Keys.sounds) ? UserDefaults.standard.bool(forKey: Keys.sounds) : true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.sounds)
        }
    }
    
    public static var vibrations: Bool {
        get {
            return keyExists(Keys.vibrations) ? UserDefaults.standard.bool(forKey: Keys.vibrations) : true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.vibrations)
        }
    }
    
    public static var backgroundGradient: BackgroundGradient {
        get {
            if keyExists(Keys.backgroundGradient) {
                return BackgroundGradient(rawValue: UserDefaults.standard.integer(forKey: Keys.backgroundGradient))!
            } else {
                return .Neon
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.backgroundGradient)
        }
    }
    
    public static var numberOfWinners: Int {
        get {
            return keyExists(Keys.numberOfWinners) ? UserDefaults.standard.integer(forKey: Keys.numberOfWinners) : 1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.numberOfWinners)
        }
    }
    
    /// Used to check if the user has modified this setting or not.
    ///
    /// - Parameters:
    ///     - key: A String representing the key for the UserDefaults dictionary.
    ///
    /// - Returns:
    ///     A boolean representing if that key exists in the dictionary or not.
    private static func keyExists(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
}
