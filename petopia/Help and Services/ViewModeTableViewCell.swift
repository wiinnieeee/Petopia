//
//  ViewModeTableViewCell.swift
//  petopia
//
//  Created by Winnie Ooi on 30/5/2023.
//

import UIKit

class ViewModeTableViewCell: UITableViewCell {
    @IBOutlet weak var viewLabel: UILabel!
    
    /// Select the mode of view based on selection on segmented control
    // Reference: https://www.youtube.com/watch?v=XghYQWWQIss
    @IBAction func selectMode(_ sender: UISegmentedControl) {
        // Default would be following the device
        PetopiaUserDefaults.shared.theme = Theme(rawValue: sender.selectedSegmentIndex) ?? .device
        self.window?.overrideUserInterfaceStyle = PetopiaUserDefaults.shared.theme.getUserInterfaceStyle()
    }
}
