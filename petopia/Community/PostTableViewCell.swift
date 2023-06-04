//
//  PostTableViewCell.swift
//  petopia
//
//  Created by Winnie Ooi on 4/6/2023.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var postingDate: UILabel!

    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var userField: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    
    
    @IBAction func reportButton(_ sender: Any) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
