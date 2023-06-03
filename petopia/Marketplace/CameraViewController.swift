//
//  CameraViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 10/5/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userReference =  Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()

    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage(title: "Error", message: "Cannot save until an image has been selected!")
            return
        }
        
        let timestamp = UInt(Date().timeIntervalSince1970)
        _ = "\(timestamp).jpg"
        
        guard let data  = image.jpegData(compressionQuality: 0.8) else { displayMessage(title: "Error", message: "Image data could not be compressed")
            return
        }
            
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage(title: "Error", message: "No user logged in!")
            return
        }
 
        let imageRef = storageReference.child("\(userID)/\(timestamp)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let uploadTask = imageRef.putData(data, metadata: metadata)
        
        uploadTask.observe(.success) {
            snapshot in
            self.userReference.document("\(userID)").collection("images").document("\(timestamp)").setData(["url" : "\(imageRef)"])
        }
        
        uploadTask.observe(.failure) { snapshot in
            self.displayMessage(title: "Error", message: "\(String(describing: snapshot.error))")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
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
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage { imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss (animated: true, completion: nil)
    }
    
    func displayMessage (title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
