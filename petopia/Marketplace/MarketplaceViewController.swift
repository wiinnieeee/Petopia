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

// Type of selection from the segmented control
let DOG_SELECTION = 0
let CAT_SELECTION = 1
let SMALL_FURY_SELECTION = 2
let RABBIT_SELECTION = 3
let BIRD_SELECTION = 4

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, DatabaseListener {
    //MARK: Listener Declaration
    var listenerType = ListenerType.listings
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
        // do nothing
    }
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
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
    
    /// Update the listings that are retrieved from the Firebase Firestore based on the type of pets chosen in the segmented control
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // Reset both lists when the type selected changes
        listingPets = []
        preListingPets = []
        // Initialise selection to be 0
        var selection = 0
        for animal in listing {
            if animal.type! == "dog"{
                selection = 0
            } else if animal.type! == "cat" {
                selection = 1
            } else if animal.type! == "small-furry" {
                selection = 2
            } else if animal.type! == "rabbit" {
                selection = 3
            } else {
                selection = 4
            }
            // Check if the animal is equivalent to the sections of the scope button
            // If yes, add the animal into the list of filteredPets
            if selection == navigationItem.searchController?.searchBar.selectedScopeButtonIndex {
                preListingPets = [animal] + preListingPets
            }
        }
        // Reload the petsCollection Collection View
        petsCollection.reloadData()
    }
    
    let PET_CELL = "petsCell"
    weak var databaseController: DatabaseProtocol?
    var authController: Auth?
    
    // Query the type of the animal selected
    var typeQuery: String = ""
    
    // Used for obtaining the pets from the API and filtering the pets
    var apiPets: [ListingAnimal] = []
    var preListingPets: [ListingAnimal] = []
    var listingPets: [ListingAnimal] = []
    
    // Manages images downloaded from the API and the Storage
    var imageURL: String = ""
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var storageReference = Storage.storage()
    
    // Collection view of the pets
    @IBOutlet weak var petsCollection: UICollectionView!
    
    /// Query API based on the type of pet selected on the scope bar of the search controller. Then, query from the Firestore using the listeners and reload the data.
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
        // Query API using the typeQuery
        configurePage()
        
        // Add listener to listen to the listings in the Firebase Firestore
        databaseController?.addListener(listener: self)
        
        // Reload the data
        petsCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        navigationItem.hidesBackButton = true
        
        authController = Auth.auth()
        
        // Initialise the properties of the Search Controller and the Search Bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for pets"
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.tintColor = UIColor(named: "General")
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Dogs", "Cats", "Hamsters", "Rabbits", "Birds"]
        
        // Attach the search controller to the navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Listen to the listings from the Firestore
        databaseController?.addListener(listener: self)
        petsCollection.reloadData()
    }
    
    /// Filter search results from the search bar based on the breed typed to find the exact breed for the user
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listingPets = []
        if searchText == "" {
            listingPets = preListingPets
        }
        for word in preListingPets {
            let isValid = (word.breed!.lowercased()).contains(searchText.lowercased())
            if isValid {
                listingPets.append(word)
            }
        }
        petsCollection.reloadData()
    }
    
    /// Directory path for the cache
    lazy var cacheDirectoryPath: URL = {
        let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cacheDirectoryPaths[0]
    }()
    
    /// Query API based on the type of pet selected on the scope bar of the search controller. Then, query from the Firestore using the listeners and reload the data.
    /// Do this every time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Query API based on the type of pet selected
        configurePage()
        
        // Query from Firestore by listening to the listings
        databaseController?.addListener(listener: self)
    }
    
    // Remove the listener once the view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    /// Configure the page to load the page and query the API results
    /// Use activity indicator as well to indicate start and stop of animation
    func configurePage () {
        // Start animation of activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.petsCollection.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Retrieve data from API
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                
                if typeQuery.count == 0 {
                    typeQuery = "dog"
                }
                
                // Query from API using the access token
                let animals = try await APIService.shared.search(token: accToken, query: typeQuery)
                apiPets = []
                
                // Load the data by making an instance of animal
                // As long as there is photo existent for the animal, it would be appended to the pets
                for pet in animals {
                    let listing = ListingAnimal()
                    listing.name = pet.name!
                    listing.gender = pet.gender!
                    listing.phoneNumber = pet.contact?.phone ?? ""
                    if (pet.photos!.count > 0) {
                        listing.imagePath = pet.photos![0].full!
                    }
                    else {
                        listing.imagePath = ""
                    }
                    listing.emailAddress = pet.contact?.email ?? ""
                    listing.type = pet.type!
                    listing.desc = pet.description ?? ""
                    listing.age = pet.age!
                    listing.breed = pet.breeds?.primary!
                    apiPets.append(listing)
                }
                // add the pets to the filtered pets
                preListingPets += apiPets
                
                // before search, listing pets is equivalent to preListing pets at initialisation
                // preListingPets include the pets listened from Firebase as well
                listingPets = preListingPets
                
                petsCollection.reloadData()
                // Stop animating when data has loaded
                activityIndicator.stopAnimating()
            }
        }
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
        let pet = listingPets[indexPath.item]
        cell.nameLabel.text! = pet.name!
        cell.breedLabel.text! = pet.breed!
        
        // Pet retrieved from Firestore would have an image ID when stored
        // During load, display a loading image as the retrieval from Firestore Storage would be slower
        if pet.imageID != nil {
            cell.imageView.image = UIImage(named: "Loading")
        }
        
        // If imageID is nil, meaning the retrieval of image is from the API
        // Download image from API
        if pet.imageID == nil {
            if pet.imageIsDownloading == false, let imageURL = pet.imagePath {
                // If there is no imageURL, load an image showing No Pet Preview
                if imageURL == "" {
                    cell.imageView.image = UIImage(named: "No Pet Preview")
                } else {
                    // obtain the imageURL and make it to a URL request
                    let requestURL = URL(string: imageURL)
                    if let requestURL {
                        Task {
                            print("Downloading image: " + imageURL)
                            pet.imageIsDownloading = true
                            do {
                                // Obtain data from URL Request
                                let (data, response) = try await URLSession.shared.data(from: requestURL)
                                guard let httpResponse = response as? HTTPURLResponse,
                                      httpResponse.statusCode == 200 else {
                                    pet.imageIsDownloading = false
                                    throw NetworkError.invalidResponse
                                }
                                // Obtain image and show in the imageView of the cell
                                if let image = UIImage(data: data) {
                                    cell.imageView.image = image
                                    print("Image shown")
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
                // If imageID is not nil
                // Meaning it's stored in the Firebase storage
                // Download the image from the Firebase storage
            }
        }else {
            let storage = Storage.storage().reference(forURL: "gs://petopiaassg.appspot.com/\(pet.ownerID!)/\(pet.imageID!)")
            let filename = ("\(pet.imageID!).jpg")
            
            // Obtain the path in local directory to download the image file
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            // Download the image and load the image data
            let downloadTask = storage.write(toFile:fileURL)
            
            // Observe the success of the downloadTask
            // If success, load image from cache and append in the imageList and imagePathList
            // And show in the imageView
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
    
    /// Load the image data from the local storage location
    func loadImageData (filename: String) -> UIImage? {
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
    // Pass the pet selected into the ViewPetViewController to view the details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSegue" {
            if let indexPath = petsCollection.indexPathsForSelectedItems?.first {
                let destination = segue.destination as? ViewPetViewController
                let petSelected = listingPets[indexPath.item]
                destination?.animal = petSelected
            }
        }
    }
}

