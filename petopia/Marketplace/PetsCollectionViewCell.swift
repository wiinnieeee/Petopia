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
    
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var heartOutlet: UIButton!
    
    var isInWishList: Bool = false
    
    weak var databaseController: (DatabaseProtocol)?

}
