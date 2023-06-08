//
//  DetailListingViewController.swift
//  petopia
//  Detail of the listings made by the user for the user to see
//
//  Created by Winnie Ooi on 3/6/2023.
//

import UIKit
import FirebaseStorage

class DetailListingViewController: UIViewController {
    
    var animal: ListingAnimal?
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialisation of the view controller based on the data passed in
        navigationItem.title = animal?.name
        breedLabel.text = animal?.breed
        genderLabel.text = animal?.gender
        ageLabel.text = animal?.age
        descriptionLabel.text = animal?.desc
        
        // If the animal doesn't have an imageID, means that it's retrieved from the API
        // We request the image from the image URL obtained from the API
        if animal?.imageID == "" {
            let imageURL = animal?.imagePath
            let requestURL = URL(string: imageURL!)
            if let requestURL {
                Task {
                    print("Downloading image: " + imageURL!)
                    do {
                        let (data, response) = try await URLSession.shared.data(from: requestURL)
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            throw NetworkError.invalidResponse
                        }
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
        }   // Or not, it's uploaded on the Firebase Storage
        // Download the image from the Firebase Storage
        // Do note that there's a quota for downloading when build everytime
        else
        {
            let storage = Storage.storage().reference(forURL: "gs://petopiaassg.appspot.com/\(animal!.ownerID!)/\(animal!.imageID!)")
            let filename = ("\(animal!.imageID!).jpg")
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            // Download the images from the storage
            let downloadTask = storage.write(toFile:fileURL)
            // Success download
            downloadTask.observe(.success) { snapshot in
                let image = self.loadImageData(filename: filename)
                self.petImage.image = image
            }
            // Fail to download
            downloadTask.observe(.failure){
                snapshot in print("\(String(describing: snapshot.error))")
            }
        }
    }
    
    ///Load the image based on the file name
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
}
