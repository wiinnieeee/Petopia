//
//  MarketplaceViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import UIKit
import FirebaseAuth

let DOG_SELECTION = 0
let CAT_SELECTION = 1
let SMALL_FURY_SELECTION = 2
let RABBIT_SELECTION = 3
let BIRD_SELECTION = 4

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    // dog, cat, small-furry, rabbit, bird
    
    weak var databaseController: DatabaseProtocol?
    var authController: Auth?
    
    @IBOutlet weak var searchBar: UISearchBar!
    var typeQuery: String = ""
    var pets: [Animal] = []
    var filteredPets: [Animal] = []
    var imageURL: String = ""
    
    let PET_CELL = "petsCell"
    
    @IBOutlet weak var petsCollection: UICollectionView!
    @IBOutlet weak var addListing: UIButton!
    
    @IBAction func logoutButton(_ sender: Any) {
        databaseController?.signOutAccount()
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        
    }
  
    @IBAction func chooseType(_ segmentedControl: UISegmentedControl ) {
        if segmentedControl.selectedSegmentIndex == DOG_SELECTION {
            typeQuery = "dog"
        } else if segmentedControl.selectedSegmentIndex == CAT_SELECTION {
            typeQuery = "cat"
        } else if segmentedControl.selectedSegmentIndex == SMALL_FURY_SELECTION {
            typeQuery = "small-furry"
        } else if segmentedControl.selectedSegmentIndex == RABBIT_SELECTION {
            typeQuery = "rabbit"
        } else if segmentedControl.selectedSegmentIndex == BIRD_SELECTION {
            typeQuery = "bird"
        }
        
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                
                let animals = try await APIService.shared.search(token: accToken, query: typeQuery)
                print(animals)
                pets = []
                filteredPets = []
                
                for pet in animals {
                    if (pet.photos!.count > 0) {
                        pets.append(pet)
                    }
                }
                filteredPets = pets
                self.petsCollection.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        //self.petsCollection.dataSource = self
        //self.petsCollection.delegate = self
        
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
                
                if typeQuery.count == 0 {
                    typeQuery = "dog"
                }
                
                let animals = try await APIService.shared.search(token: accToken, query: typeQuery)
                pets = []
                filteredPets = []
                
                for pet in animals {
                    if (pet.photos!.count > 0) {
                        pets.append(pet)
                    }
                }
                filteredPets = pets
                self.petsCollection.reloadData()
            }
        }
        
        
            
        let layout = UICollectionViewCompositionalLayout(section: createTiledLayoutSection())
        petsCollection.setCollectionViewLayout(layout, animated: false)
        petsCollection.reloadData()

    }
//
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPets = []
        if searchText == "" {
            filteredPets = pets
        }
        for word in pets {
            let isValid = (word.breeds?.primary?.lowercased())!.contains(searchText.lowercased())
            if isValid {
                filteredPets.append(word)
            }
        }
        self.petsCollection.reloadData()
    }
    
    lazy var cacheDirectoryPath: URL = {
        let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cacheDirectoryPaths[0]
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor.systemPink
        typeQuery = "dog"
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

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.55))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [posterLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        //layoutSection.orthogonalScrollingBehavior = .continuous
        return layoutSection
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PET_CELL, for: indexPath) as! PetsCollectionViewCell? else {
            fatalError("Unable to dequeue")
        }
        var pet = filteredPets[indexPath.row]
        cell.nameLabel.text! = pet.name!
        cell.breedLabel.text! = (pet.breeds?.primary)!
        
        // Make sure the image is blank after cell reuse.
        cell.imageView?.image = nil

        
        if let image = pet.image {
            cell.imageView.image = image
        }
        else if pet.imageIsDownloading == false, let imageURL = pet.photos![0].full {
            let requestURL = URL(string: imageURL)
            if let requestURL {
                Task {
                    print("Downloading image: " + imageURL)
                    pet.imageIsDownloading = true
                    do {
                        let (data, response) = try await URLSession.shared.data(from: requestURL)
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            pet.imageIsDownloading = false
                            throw NetworkError.invalidResponse
                        }

                        if let image = UIImage(data: data) {
                            print("Image downloaded: " + imageURL)
                            pet.image = image
                            cell.imageView.image = image
                        }
                        else {
                            print("Image invalid: " + imageURL)
                            pet.imageIsDownloading = false
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                    }

                }
            }
            else {
                print("Error: URL not valid: " + imageURL)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        <#code#>
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
