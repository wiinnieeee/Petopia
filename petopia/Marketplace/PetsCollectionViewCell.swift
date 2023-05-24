//
//  PetsCollectionViewCell.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PetsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var heartOutlet: UIButton!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var databaseController: (DatabaseProtocol)?
    
    var isInWishList: Bool = false
    
    //ask
    @IBAction func buttonPress(_ sender: UIButton) {
        // "Use this method to toggle a Boolean value from true to false or from false to true." [ Apple Doc ]
        isInWishList = !isInWishList
        
        if isInWishList {
            heartOutlet.setImage(UIImage(named: "heart.fill"), for: .normal)
        } else {
            heartOutlet.setImage(UIImage(named: "heart"), for: .normal)
        }
    }
}
