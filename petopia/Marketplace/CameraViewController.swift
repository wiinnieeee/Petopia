//
//  CameraViewController.swift
//  petopia
//  View controller to select the image to be put in the new listing
//
//  Created by Winnie Ooi on 10/5/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Reference the user and storage
    var userReference =  Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    
    @IBOutlet weak var imageView: UIImageView!

    ///Save the photo from the photo library or the camera
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage(title: "Error", message: "Cannot save until an image has been selected!")
            return
        }
        
        let timestamp = UInt(Date().timeIntervalSince1970)
        _ = "\(timestamp).jpg"
        
        // Compress the image
        guard let data  = image.jpegData(compressionQuality: 0.8) else { displayMessage(title: "Error", message: "Image data could not be compressed")
            return
        }
            
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage(title: "Error", message: "No user logged in!")
            return
        }

        // Create a new imageRef id using the userID and the timestamp
        let imageRef = storageReference.child("\(userID)/\(timestamp)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Upload the image to the imageRef which is the Firebase Storage
        let uploadTask = imageRef.putData(data, metadata: metadata)
        
        // If success, it would be stored in the collection of images in the user as well
        uploadTask.observe(.success) {
            snapshot in
            self.userReference.document("\(userID)").collection("images").document("\(timestamp)").setData(["url" : "\(imageRef)"])
        }
        
        uploadTask.observe(.failure) { snapshot in
            self.displayMessage(title: "Error", message: "\(String(describing: snapshot.error))")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    /// Action to pick and select the photo using the action sheet
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        // Disable editing of the image
        controller.allowsEditing = false
        controller.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: "Select Option:", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in controller.sourceType = .camera
        self.present(controller, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in controller.sourceType = .photoLibrary
        self.present(controller, animated: true, completion: nil)
        }
        
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { action in controller.sourceType = .savedPhotosAlbum
        self.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) { actionSheet.addAction(cameraAction)
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Method to store image after it is selected from the source
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage { imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss (animated: true, completion: nil)
    }
    
    /// Initialise a view controller used to display message
    func displayMessage (title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
