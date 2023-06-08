//
//  PetopiaUserDefaults.swift
//  petopia
//  Setup for light and dark mode user defaults
//
//  Created by Winnie Ooi on 30/5/2023.
//

import Foundation
import UIKit

struct PetopiaUserDefaults {
    // Static variable to declare te user defaults
    static var shared = PetopiaUserDefaults()
    
    /// Set and get the user defaults for the theme (view mode)
    var theme: Theme {
        get {
            return Theme(rawValue: UserDefaults.standard.integer(forKey: "selectedTheme")) ?? .device
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
        }
    }
}
