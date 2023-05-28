//
//  ViewPetViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 21/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class ViewPetViewController: UIViewController {

    @IBOutlet weak var typeBreedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var vaccLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBAction func addWishlist(_ sender: Any) {
        databaseController?.addAnimaltoWishlist(newAnimal: animal)
    }
     
    var animal: Animal?
    var imageURL: String = ""
    var nameText: String = ""
    var breedText: String = ""
    var ageText: String = ""
    var genderText: String = ""
    var vaccText: String = ""
    var descText: String = ""
    var emailText: String = ""
    var phoneText: String = ""
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestURL = URL(string: imageURL)
            if let requestURL {
                Task {
                    print("Downloading image: " + imageURL)
                    do {
                        let (data, response) = try await URLSession.shared.data(from: requestURL)
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            throw NetworkError.invalidResponse
                        }
                        if let image = UIImage(data: data) {
                            petImageView.image = image
                        }
                        else {
                            print("Image invalid: " + imageURL)
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

        // Do any additional setup after loading the view.
        nameLabel.text = nameText
        typeBreedLabel.text = breedText
        ageLabel.text = ageText
        genderLabel.text = genderText
        vaccLabel.text = vaccText
        descriptionLabel.text = descText
        emailLabel.text = emailText
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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
