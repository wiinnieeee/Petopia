//
//  ReminderCollectionView.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import UIKit

//class ReminderCollectionView: UICollectionView {
//    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
//    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
//
//    var dataSource: DataSource!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let listlayout = listLayout()
//        collectionView.collectionViewLayout = listlayout
//
//        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
//
//        dataSource = DataSource(collectionView: collectionView) {
//            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: String) in
//
//            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
//        }
//
//        var snapshot = Snapshot ()
//        snapshot.appendSections([0])
//        snapshot.appendItems(Reminder.sampleData.map {$0.title})
//        dataSource.apply(snapshot)
//
//        collectionView.dataSource = dataSource
//    }
    
//    private func listLayout() -> UICollectionViewCompositionalLayout{
//        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
//        listConfiguration.showsSeparators = false
//        listConfiguration.backgroundColor = .clear
//        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
//
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of items
//        return 0
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//    
//        // Configure the cell
//    
//        return cell
//    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

