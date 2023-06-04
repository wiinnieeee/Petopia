//
//  MarketplaceViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

let DOG_SELECTION = 0
let CAT_SELECTION = 1
let SMALL_FURY_SELECTION = 2
let RABBIT_SELECTION = 3
let BIRD_SELECTION = 4

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, DatabaseListener {
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
        // do nothing
    }
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    
    var listenerType = ListenerType.listings
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        // do nothing
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        listingPets = []
        filteredPets = []
        var selection = 0
        for animal in listing {
            if animal.type! == "dog"{
                selection = 0
            } else if animal.type! == "cat" {
                selection = 1
            } else if animal.type! == "small-fury" {
                selection = 2
            } else if animal.type! == "rabbit" {
                selection = 3
            } else {
                selection = 4
            }
            if selection == navigationItem.searchController?.searchBar.selectedScopeButtonIndex {
                filteredPets = [animal] + filteredPets
            }
        }
        petsCollection.reloadData()
    }
    
    // dog, cat, small-furry, rabbit, bird
    
    weak var databaseController: DatabaseProtocol?
    var authController: Auth?
    
    var typeQuery: String = ""
    var pets: [ListingAnimal] = []
    var filteredPets: [ListingAnimal] = []
    var listingPets: [ListingAnimal] = []
    var imageURL: String = ""
    var snapshotListener: ListenerRegistration?
    var storageReference = Storage.storage()
    var imageList = [UIImage]()
    var imagePathList = [String]()
    
    
    let PET_CELL = "petsCell"

    @IBOutlet weak var petsCollection: UICollectionView!
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == DOG_SELECTION {
            typeQuery = "dog"
        } else if selectedScope == CAT_SELECTION {
            typeQuery = "cat"
        } else if selectedScope == SMALL_FURY_SELECTION {
            typeQuery = "small-furry"
        } else if selectedScope == RABBIT_SELECTION {
            typeQuery = "rabbit"
        } else if selectedScope == BIRD_SELECTION {
            typeQuery = "bird"
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.petsCollection.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                
                let animals = try await APIService.shared.search(token: accToken, query: typeQuery)
                pets = []
                
                for pet in animals {
                    if (pet.photos!.count > 0) {
                        let listing = ListingAnimal()
                        listing.name = pet.name!
                        listing.gender = pet.gender!
                        listing.phoneNumber = pet.contact?.phone ?? ""
                        listing.imagePath = pet.photos![0].full!
                        listing.emailAddress = pet.contact?.email ?? ""
                        listing.type = pet.type!
                        listing.desc = pet.description ?? ""
                        listing.breed = pet.breeds?.primary!
                        listing.age = pet.age!
                
                        pets.append(listing)
                    }
                }
                filteredPets += pets
                listingPets = filteredPets
                self.petsCollection.reloadData()
                activityIndicator.stopAnimating()
            }
        }
        databaseController?.addListener(listener: self)
        petsCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        navigationItem.hidesBackButton = true
    
        authController = Auth.auth()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for pets"
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.tintColor = UIColor(named: "general")
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Dogs", "Cats", "Hamsters", "Rabbits", "Birds"]
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.petsCollection.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
            
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                
                if typeQuery.count == 0 {
                    typeQuery = "dog"
                }
                
                let animals = try await APIService.shared.search(token: accToken, query: typeQuery)
                pets = []
                
                for pet in animals {
                    if (pet.photos!.count > 0) {
                        let listing = ListingAnimal()
                        listing.name = pet.name!
                        listing.gender = pet.gender!
                        listing.phoneNumber = pet.contact?.phone ?? ""
                        listing.imagePath = pet.photos![0].full!
                        listing.emailAddress = pet.contact?.email ?? ""
                        listing.type = pet.type!
                        listing.desc = pet.description ?? ""
                        listing.age = pet.age!
                        listing.breed = pet.breeds?.primary!
                        pets.append(listing)
                    }
                }
                filteredPets += pets
                listingPets = filteredPets
                self.petsCollection.reloadData()
                activityIndicator.stopAnimating()
            }
        }
        
        let layout = UICollectionViewCompositionalLayout(section: createTiledLayoutSection())
        petsCollection.setCollectionViewLayout(layout, animated: false)
        
        databaseController?.addListener(listener: self)
        petsCollection.reloadData()
        
    }
    
    
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listingPets = []
        if searchText == "" {
            listingPets = filteredPets
        }
        for word in filteredPets {
            let isValid = (word.breed!.lowercased()).contains(searchText.lowercased())
            if isValid {
                listingPets.append(word)
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
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.petsCollection.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
            
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                
                if typeQuery.count == 0 {
                    typeQuery = "dog"
                }
                
                let animals = try await APIService.shared.search(token: accToken, query: typeQuery)
                pets = []
                
                for pet in animals {
                    if (pet.photos!.count > 0) {
                        let listing = ListingAnimal()
                        listing.name = pet.name!
                        listing.gender = pet.gender!
                        listing.phoneNumber = pet.contact?.phone ?? ""
                        listing.imagePath = pet.photos![0].full!
                        listing.emailAddress = pet.contact?.email ?? ""
                        listing.type = pet.type!
                        listing.desc = pet.description ?? ""
                        listing.age = pet.age!
                        listing.breed = pet.breeds?.primary!
                        pets.append(listing)
                    }
                }
                filteredPets += pets
                listingPets = filteredPets
                
                self.petsCollection.reloadData()
                activityIndicator.stopAnimating()
            }
        }
        databaseController?.addListener(listener: self)
        petsCollection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        petsCollection.reloadData()
    }

    func createTiledLayoutSection() -> NSCollectionLayoutSection {
        let posterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let posterLayout = NSCollectionLayoutItem(layoutSize: posterSize)
        posterLayout.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.55))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [posterLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        return layoutSection
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingPets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PET_CELL, for: indexPath) as! PetsCollectionViewCell? else {
            fatalError("Unable to dequeue")
        }
        print(indexPath.row)
        let pet = listingPets[indexPath.row]
        cell.nameLabel.text! = pet.name!
        cell.breedLabel.text! = pet.breed!
        
        // Make sure the image is blank after cell reuse.
        cell.imageView?.image = nil
        
        if pet.imageID == nil {
            if pet.imageIsDownloading == false, let imageURL = pet.imagePath {
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
        } else {
            let storage = Storage.storage().reference(forURL: "gs://petopiaassg.appspot.com/\(pet.ownerID!)/\(pet.imageID!)")
            let filename = ("\(pet.imageID!).jpg")
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            let downloadTask = storage.write(toFile:fileURL)
            downloadTask.observe(.success) { snapshot in
                let image = self.loadImageData(filename: filename)
                self.imageList.append(image!)
                self.imagePathList.append(filename)
                cell.imageView.image = image
            }
            
            
            downloadTask.observe(.failure){
                snapshot in print("\(String(describing: snapshot.error))")
            }
        }
        return cell
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewSegue", sender: self)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSegue" {
            if let indexPath = petsCollection.indexPathsForSelectedItems?.first {
                let destination = segue.destination as? ViewPetViewController
                let petSelected = filteredPets[indexPath.row]
                destination?.animal = petSelected
            }
        }
    }
}
