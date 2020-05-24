//
//  UserStatistics.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 2/18/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation

struct UserStatistics {
    
    private enum Keys {
        static let appLaunches = "APPLAUNCHES"
        static let timesChosen = "TIMESCHOSEN"
    }
    
    public static var appLaunches: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.appLaunches)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appLaunches)
        }
    }
    
    public static var timesChosen: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.timesChosen)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.timesChosen)
        }
    }
    
}
