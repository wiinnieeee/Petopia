//
//  MarketplaceViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import UIKit
import FirebaseAuth

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    weak var databaseController: DatabaseProtocol?
    var authController: Auth?
    
    var typeQuery: String = ""
    var pets: [Animal] = []
    
    let PET_CELL = "petsCell"
    
    @IBOutlet weak var petsCollection: UICollectionView!
    @IBOutlet weak var addListing: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func logoutButton(_ sender: Any) {
        databaseController?.signOutAccount()
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        //self.petsCollection.dataSource = self
        //self.petsCollection.delegate = self
        
        //how to disable the back button owo
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.systemPink
        addListing.contentMode = .scaleAspectFit
        
        
        navigationItem.largeTitleDisplayMode = .never
        
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        authController = Auth.auth()
        searchBar.searchTextField.backgroundColor = .white
        
        
        
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                let animals = try await APIService.shared.search(token: accToken)
                
                pets = animals
                self.petsCollection.reloadData()
            }
            
        let layout = UICollectionViewCompositionalLayout(section: createTiledLayoutSection())
        petsCollection.setCollectionViewLayout(layout, animated: false)
        petsCollection.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor.systemPink
    }
    
    
    func createTiledLayoutSection() -> NSCollectionLayoutSection {
        // Tiled layout.
        //  * Group is three posters, side-by-side.
        //  * Group is 1 x screen width, and height is 1/2 x screen width (poster height)
        //  * Poster width is 1/3 x group width, with height as 1 x group width
        //  * This makes item dimensions 2:3
        //  * contentInsets puts a 1 pixel margin around each poster.
        let posterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let posterLayout = NSCollectionLayoutItem(layoutSize: posterSize)
        posterLayout.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/2))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [posterLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        //layoutSection.orthogonalScrollingBehavior = .continuous
        return layoutSection
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PET_CELL, for: indexPath) as! PetsCollectionViewCell? else {
            fatalError("Unable to dequeue")
        }
        let pet = pets[indexPath.row]
        
        cell.nameLabel.text! = pet.name!
 
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
