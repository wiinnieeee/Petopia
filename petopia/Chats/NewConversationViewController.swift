//
//  NewConversationViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 5/6/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class NewConversationViewController: UIViewController{
    
    var userList = [SimpleUser]()
    var filteredList = [SimpleUser]()
    
    var usersRef: CollectionReference?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        //navigationItem.rightBarButtonItem?.tintColor = UIColor(named: ".general")
        searchBar.becomeFirstResponder()
        setupAllUsersListener()
        tableView.reloadData()
        print(filteredList)
        print(userList)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func setupAllUsersListener() {
        let usersRef = Firestore.firestore().collection("users")
        usersRef.addSnapshotListener(){
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error")
                return
            }
            
            self.parseAllUsersListener(querySnapshot: querySnapshot)
        }
    }
    
    func parseAllUsersListener(querySnapshot: QuerySnapshot){
        querySnapshot.documentChanges.forEach {
            (change) in
            var parsedUser: SimpleUser?
            
            do {
                parsedUser = try change.document.data(as: SimpleUser.self)
            } catch {
                print("Unable to decode user")
                return
            }
            
            guard let user = parsedUser else {
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added {
                self.userList.insert(user, at: Int(change.newIndex))
            } else if change.type == .modified {
                self.userList [Int (change.oldIndex)] = user
            } else if change.type == .removed {
                self.userList.remove(at: Int(change.oldIndex))
            }
        }
        tableView.reloadData()
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


extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = filteredList[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredList = []
        if searchText == "" {
            filteredList = userList
        }
        for user in userList {
            let isValid = (user.name!.lowercased()).contains(searchText.lowercased())
            if isValid {
                filteredList.append(user)
            }
        }
        self.tableView.reloadData()
    }
    
    
//    //listingPets = []
//    if searchText == "" {
//        listingPets = filteredPets
//    }
//    for word in filteredPets {
//        let isValid = (word.breed!.lowercased()).contains(searchText.lowercased())
//        if isValid {
//            listingPets.append(word)
//        }
//    }
//    self.petsCollection.reloadData()
}
