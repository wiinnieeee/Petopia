//
//  NewListingViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 10/5/2023.
//

import UIKit
import CoreData

class NewListingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var imageCollectionView: UICollectionView!

    @IBOutlet weak var imageView: UIImageView!
    private let reuseIdentifier = "Cell"
    
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageCollectionView!.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer?.viewContext
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            let imageDataList = try managedObjectContext!.fetch(ImageMetaData.fetchRequest()) as [ImageMetaData]
            for data in imageDataList {
            let filename = data.fileName!
            if imagePathList.contains(filename) { print("Image Already loaded. Skipping image")
                continue
            }
            if let image = loadImageData(filename: filename)
                { imageList.append(image)
                imagePathList.append(filename)
                self.imageCollectionView.reloadSections([0])
            } }
        } catch {
            print("Unable to fetch images")
        }
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
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
