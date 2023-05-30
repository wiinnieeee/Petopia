//
//  UserDefaults.swift
//  petopia
//
//  Created by Winnie Ooi on 30/5/2023.
//

import Foundation
import UIKit

struct PetopiaUserDefaults {
    static var shared = PetopiaUserDefaults()
    
    var theme: Theme {
        get {
            return Theme(rawValue: UserDefaults.standard.integer(forKey: "selectedTheme")) ?? .device
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
        }
    }
}
