//
//  ConversationTableViewCell.swift
//  petopia
//
//  Created by Winnie Ooi on 5/6/2023.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var userMessageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
