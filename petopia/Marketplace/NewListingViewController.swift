//
//  NewListingViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 10/5/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class NewListingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DatabaseListener {
    
    
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
    
    var listenerType: ListenerType = ListenerType.users
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        currentUser = user
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var imageView: UIImageView!
    private let reuseIdentifier = "Cell"
    
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var genderField: UISegmentedControl!
    @IBOutlet weak var petNameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var breedField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imagePathList = [String]()
    
    var userReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage()
    var snapshotListener: ListenerRegistration?
    
    var currentUser: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        imageCollectionView.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        imageCollectionView.reloadData()
    }
    
    @IBAction func createListingButton(_ sender: Any) {
        guard let name = petNameField.text, let age = ageField.text, let breed = breedField.text, let desc = descriptionField.text else {
            return
        }
        var type: String? = "dog"
        switch typeField.selectedSegmentIndex {
            case 1:
                type = "cat"
            case 2:
                type = "small-furry"
            case 3:
                type = "rabbit"
            case 4:
                type = "bird"
            default:
                type = "dog"
        }
        
        var gender: String? = "Male"
        switch genderField.selectedSegmentIndex {
        case 1:
            gender = "Male"
        default:
            gender = "Female"
        }
        
        let newListing = ListingAnimal()
        newListing.name = name
        newListing.age = age
        newListing.breed = breed
        newListing.desc = desc
        newListing.type = type
        newListing.gender = gender
        
        newListing.ownerID = Auth.auth().currentUser?.uid
        
        newListing.emailAddress = currentUser.email
        newListing.phoneNumber = currentUser.phoneNumber
        newListing.imageID = imagePathList[0].replacingOccurrences(of: ".jpg", with: "")

        databaseController?.addAnimaltoListing(newAnimal: newListing)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userImagesRef = userReference.document(userID).collection("images")
        
        snapshotListener = userImagesRef.addSnapshotListener() { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { print(error!)
                return
            }
            self.parseSnapshot(snapshot: querySnapshot)
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        if let snapshotListener = snapshotListener {
            snapshotListener.remove()
        }
        databaseController?.removeListener(listener: self)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! ImageCollectionViewCell
        cell.backgroundColor = .secondarySystemFill
        cell.imageView.image = imageList[indexPath.row]
        return cell
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
        let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
        imageItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2,
                                                          bottom: 2, trailing: 2)
        
        let imageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .fractionalWidth(1/3))
        
        let imageGroup = NSCollectionLayoutGroup.horizontal(layoutSize: imageGroupSize, subitems: [imageItem])
        
        let imageSection = NSCollectionLayoutSection(group: imageGroup)
        return UICollectionViewCompositionalLayout(section: imageSection)
    }
    
    func saveImageData(filename: String, imageData: Data) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print ("Error writing file: \(error.localizedDescription)")
        }
    }
    
    func parseSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            change in
            
            let imageName = change.document.documentID
            let imageURL = change.document.data()["url"] as! String
            let filename = ("\(imageName).jpg")
            
            if change.type == .added {
                if !self.imagePathList.contains(filename) {
                    if let image = self.loadImageData(filename: filename) {
                        self.imageList.append(image)
                        self.imagePathList.append(filename)
                        self.imageCollectionView.reloadSections([0])
                    }
                    else {
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let documentsDirectory = paths[0]
                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                        let downloadTask = storageReference.reference(forURL: imageURL).write(toFile:fileURL)
                        downloadTask.observe(.success) { snapshot in
                            let image = self.loadImageData(filename: filename)
                            self.imageList.append(image!)
                            self.imagePathList.append(filename)
                            self.imageCollectionView.reloadSections([0])
                        }
                        downloadTask.observe(.failure){ snapshot in print("\(String(describing: snapshot.error))")
                        }
                    }
                }
            } else if change.type == .removed {
                if let index = self.imagePathList.firstIndex(of: filename) {
                    self.imagePathList.remove(at: index)
                }
            }
        }
    }
        
        
        func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let deleteController = UIAlertController(title: "Delete Image?", message: "Do you want to delete the image? Changes cannot be reversed", preferredStyle: .alert)
            
            deleteController.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
                action -> Void in
                
                self.imageCollectionView.deleteItems(at: [indexPath])
                self.imageList.remove(at: indexPath.row)
                
                let imagePath = self.imagePathList[indexPath.row]
                let imageID = imagePath.replacingOccurrences(of: ".jpg", with: "")
                
                self.databaseController?.deleteImage(image: imageID)
                
            }))
            
            deleteController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(deleteController, animated: true)
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
