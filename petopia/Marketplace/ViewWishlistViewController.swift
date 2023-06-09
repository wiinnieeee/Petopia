//
//  ViewWishlistViewController.swift
//  petopia
//  Controller to view the wishlist
//
//  Created by Winnie Ooi on 1/6/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MessageUI

class ViewWishlistViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    var animal: WishlistAnimal?
    
    @IBOutlet weak var petImage: UIImageView!
    
    @IBOutlet weak var ageField: UILabel!
    @IBOutlet weak var genderField: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var descField: UILabel!
    
    
    @IBAction func contactButton(_ sender: Any) {
        let message = "Email: \((self.animal?.emailAddress ?? "")!)\nPhone number: \((self.animal?.phoneNumber ?? "" )!)"
        let alert = UIAlertController(title: "Contact Owner", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Email owner", style: .default, handler: { action in
            self.showMailComposer()
        }))
        alert.addAction(UIAlertAction(title: "Text owner", style: .default, handler: { action in
            self.showMessageComposer()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If imageID is nil, meaning the retrieval of image is from the API
        // Download image from the imagePath provided by the API
        // Similar to image retrieval in MarketplaceViewController
        if animal?.imageID == "" {
            let imageURL = animal?.imageURL!
            // If there is no imageURL, load an image showing No Pet Preview
            if imageURL == "" {
                petImage.image = UIImage(named: "No Pet Preview")
            } else {
                let imageURL = animal?.imageURL
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
                                petImage.image = image
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
        }else {
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
                self.petImage.image = image
            }
            downloadTask.observe(.failure){
                snapshot in print("\(String(describing: snapshot.error))")
            }
        }
        
        // Initialise the labels to display the attributes
        ageField.text = animal?.age
        breedLabel.text = animal?.breed
        genderField.text = animal?.gender
        descField.text = animal?.description
        
        // Allow description label to have infinite number of lines
        descField.numberOfLines = 0
        
        navigationItem.title = animal?.name
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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

