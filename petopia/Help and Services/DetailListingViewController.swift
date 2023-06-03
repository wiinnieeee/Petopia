//
//  DetailListingViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 3/6/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class DetailListingViewController: UIViewController {
    var animal: ListingAnimal?
    
    @IBOutlet weak var petImage: UIImageView!
    
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        navigationItem.title = animal?.name
        breedLabel.text = animal?.breed
        genderLabel.text = animal?.gender
        ageLabel.text = animal?.age
        descriptionLabel.text = animal?.desc
        
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
        } else {
            let storage = Storage.storage().reference(forURL: "gs://petopiaassg.appspot.com/\(animal!.ownerID!)/\(animal!.imageID!)")

            storage.getData(maxSize: 15 * 1024 * 1024) { data, error in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                } else{
                    let image = UIImage(data: data!)
                    self.petImage.image = image
                    
                    storage.downloadURL { url, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "error")
                        } else {
                            print(url ?? "url")
                            
                        }
                    }
                }
            }
        }
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
