//
//  TabbarViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 27/4/2023.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Hides the back button of the view controller
        navigationItem.hidesBackButton = true
        // Hide the navigation bar as well
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
