//
//  ViewModeTableViewCell.swift
//  petopia
//
//  Created by Winnie Ooi on 30/5/2023.
//

import UIKit

class ViewModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func selectMode(_ sender: UISegmentedControl) {
        PetopiaUserDefaults.shared.theme = Theme(rawValue: sender.selectedSegmentIndex) ?? .device
        self.window?.overrideUserInterfaceStyle = PetopiaUserDefaults.shared.theme.getUserInterfaceStyle()
    }
    
}
