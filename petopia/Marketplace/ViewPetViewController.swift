//
//  ViewPetViewController.swift
//  petopia
//  View the details of pet, provide functionality to add wishlist and contact owner
//
//  Created by Winnie Ooi on 21/5/2023.
//

import UIKit
import MessageUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ViewPetViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    // Completion handler to be handled when a conversation is successfully started
    public var completion: ((User) -> (Void))?
    
    // Check if the conversation is already present
    var isPresent: Bool = false
    
    //
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    var isFireBase: Bool?  = false
    var otherUser: User?
    var animal: ListingAnimal?
    
    // Labels for the pet details
    @IBOutlet weak var typeBreedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // Outlets for the buttons
    @IBOutlet weak var contactOutlet: UIButton!
    @IBOutlet weak var wishlistOutlet: UIButton!
    
    /// Add the pet to the wishlist of the user
    @IBAction func addWishlist(_ sender: Any) {
        // Construct a wishlist animal instance based on the details passed in
        let newRow = WishlistAnimal(breed: (animal?.breed)!, age: (animal?.age)!, gender: (animal?.gender)!, name: (animal?.name)!, type: (animal?.type)!, description: animal?.desc ?? "", emailAddress: (animal?.emailAddress)!, phoneNumber: (animal?.phoneNumber)!, imageID: animal?.imageID, imageURL: animal?.imagePath, ownerID: animal?.ownerID)
        
        // Add animal to wishlist of the Firebase Firestore
        // Check for duplicates at the same time
        databaseController?.addAnimaltoWishlist(newAnimal: newRow) {isDuplicate in
            if isDuplicate {
                // Show alert if animal is already a duplicate in the wishlist
                let alertController = UIAlertController(title: "Duplicate Entry", message: "This animal is already in the wishlist.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    /// Allow the user to contact the owner of the pet
    @IBAction func contactButton(_ sender: Any) {
        let usersRef = db.collection("users")
        
        // Check user documents if owner of pet is in the firebase
        usersRef.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                // If the user is in the Firebase
                // We get the user details from the Firebase
                // And make isInFirebase true
                var isInFireBase = false
                let user2 = User()
                for document in querySnapshot!.documents {
                    print(document.data()["emailAdd"]!)
                    if self?.animal?.emailAddress == document.data()["emailAdd"] as? String {
                        isInFireBase = true
                        user2.id = document.documentID
                        user2.name = document.data()["name"] as? String
                        user2.phoneNumber = document.data()["phoneNumber"] as? String
                        user2.email = document.data()["emailAdd"] as? String
                        break
                    }
                }
                // Update the isFirebase variable in the main
                DispatchQueue.main.async { [self] in // Update the property on the main thread
                    self?.isFireBase = isInFireBase
                    
                    // If owner is existent in the Firebase
                    // The current user can chat with the owner
                    if self?.isFireBase == true {
                        // Connect to chat controller
                        self?.otherUser = user2
                        // Check if the conversation between user and the same pet is already existent
                        // If not present, create a new conversation
                        if !(self!.isPresent) {
                            self?.createNewConversation(result: (self?.otherUser)!)
                        }
                        // If present, display a warning
                        else {
                            let message = "You have already had a conversation with this user!"
                            let alert = UIAlertController(title: "Conversation Created", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Go to Chat", style: .default, handler: { action in
                                self?.performSegue(withIdentifier: "chatSegue", sender: nil)
                            }))
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                        // If the owner is not recorded in the database
                        // which means it's from the API
                        // Display action for the user to email or text the owner
                        // Provide the details of email and phone number in the alert controller as well
                        // Redirect to SMS and Email unable to show in simulator
                    } else {
                        let message = "Email: \((self?.animal?.emailAddress ?? "")!)\nPhone number: \((self?.animal?.phoneNumber ?? "" )!)"
                        let alert = UIAlertController(title: "Contact Owner", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Email owner", style: .default, handler: { action in
                            self?.showMailComposer()
                        }))
                        alert.addAction(UIAlertAction(title: "Text owner", style: .default, handler: { action in
                            self?.showMessageComposer()
                        }))
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                        
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    /// Creating new conversation with the other user
    func createNewConversation (result: User) {
        guard let name = result.name, let _ = result.email, let _ = result.id else {
            return
        }
        // Pass the required variable to the Chat View Controller
        let vc = ChatViewController()
        vc.title = "\(name) - \((animal?.name)!)"
        vc.animal = animal
        vc.otherUser = result
        vc.isNewConversation = true
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If imageID is nil, meaning the retrieval of image is from the API
        // Download image from the imagePath provided by the API
        // Similar to image retrieval in MarketplaceViewController
        if animal?.imageID == nil {
            let imageURL = animal?.imagePath!
            // If there is no imageURL, load an image showing No Pet Preview
            if imageURL == "" {
                petImageView.image = UIImage(named: "No Pet Preview")
            } else {
                // obtain the imageURL and make it to a URL request
                let requestURL = URL(string: imageURL!)
                if let requestURL {
                    Task {
                        print("Downloading image: " + imageURL!)
                        do {
                            // Obtain data from URL Request
                            let (data, response) = try await URLSession.shared.data(from: requestURL)
                            guard let httpResponse = response as? HTTPURLResponse,
                                  httpResponse.statusCode == 200 else {
                                throw NetworkError.invalidResponse
                            }
                            // Obtain image and show in the imageView
                            if let image = UIImage(data: data) {
                                petImageView.image = image
                            }
                            else {
                                print("Image invalid: " + imageURL!)
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else {
                    print("Error: URL not valid: " + imageURL!)
                }
                // If imageID is not nil
                // Meaning it's stored in the Firebase storage
                // Download the image from the Firebase storage
            }
        }
        else {
            let storage = Storage.storage().reference(forURL: "gs://petopiaassg.appspot.com/\(animal!.ownerID!)/\(animal!.imageID!)")
            let filename = ("\(animal!.imageID!).jpg")
            
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
                self.petImageView.image = image
            }
            downloadTask.observe(.failure){
                snapshot in print("\(String(describing: snapshot.error))")
            }
        }
        
        // Initialise the labels to display the attributes
        ageLabel.text = animal?.age!
        breedLabel.text = animal?.breed!
        genderLabel.text = animal?.gender!
        descriptionLabel.text = animal?.desc
        
        // Allow description label to have infinite number of lines
        descriptionLabel.numberOfLines = 0
        
        navigationItem.title = animal?.name!
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Check if the conversation is present
        let conversationsRef = db.collection("conversations")
        conversationsRef.getDocuments { [self]
            (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var isPresentDoc = false
                for document in querySnapshot!.documents {
                    // If the user has contacted the owner and queried about the animal before
                    // The conversation is already present
                    // Don't allow to create a new conversation
                    if self.animal?.name! == document.data()["animal"] as? String && Auth.auth().currentUser?.uid == document.data()["contactUser"] as? String {
                        isPresentDoc = true
                        break
                    }
                }
                // Update property in the main thread
                DispatchQueue.main.async { [self] in
                    self.isPresent = isPresentDoc
                }
            }
        }
        // If the listing is done by the user
        // Hide the option to save to wishlist and contact
        if animal?.emailAddress == Auth.auth().currentUser?.email! {
            contactOutlet.isHidden = true
            wishlistOutlet.isHidden = true
        }
    }
    
    /// Load the image data from the local storage location
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    /// If email sending function is enables, present the mail composer
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        // Set the delegate to this view controller
        // The recipient configured would be the email address of the owner
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["\((animal?.emailAddress)!)"])
        
        present(composer, animated: true)
    }
    
    /// Display the result of the Mail Compose Controller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
            return
        }
        
        // Print results accordingly
        switch result {
        case .cancelled:
            print ("Cancelled")
        case .saved:
            print ("Saved")
        case .sent:
            print ("Email sent")
        case .failed:
            print ("Failed to send")
        @unknown default:
            print("Error")
        }
        
        controller.dismiss(animated: true)
    }
    
    /// If message sending function is enables, present the mail composer
    func showMessageComposer() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        
        // Set the delegate to this view controller
        // The recipient configured would be the phone number of the owner
        let composer = MFMessageComposeViewController()
        composer.recipients = [(animal?.phoneNumber)!]
        composer.messageComposeDelegate = self
        
        present(composer, animated: true)
    }
    
    /// Display the result of the Message Compose Controller
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print ("Cancelled case")
        case .sent:
            print ("Sent case")
        case .failed:
            print ("Failed case")
        @unknown default:
            print("Error")
        }
        controller.dismiss(animated: true
        )
    }
}
