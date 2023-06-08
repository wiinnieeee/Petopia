//
//  PostTableViewCell.swift
//  petopia
//
//  Created by Winnie Ooi on 4/6/2023.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    var parentVC: UITableViewController!
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var postingDate: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var userField: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    
    /// Report the post if deemed inappropiate
    @IBAction func reportButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Report Post", message: "Are you sure that you want to report this post as inappropiate?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Report", style: .default))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        parentVC.present(alertController, animated: true)
    }
}
