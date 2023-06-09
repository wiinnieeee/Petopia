//
//  TrackerReminderViewController.swift
//  petopia
//  A main view controller for the user to view the existing reminders, no matter done or not
//
//  Created by Winnie Ooi on 8/5/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TrackerReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    // MARK: Listener Declaration
    var listenerType = ListenerType.reminders
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
        // do nothing
    }
    
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        reminder = reminders
        reminderView.reloadData()
    }
    
    @IBOutlet weak var calendarPicker: UIDatePicker!
    @IBOutlet weak var reminderView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    
    let CELL_REMINDER = "reminderCell"
    
    var currentUser = Auth.auth().currentUser
    var reminder = [Reminder]()
    var remindersRef: CollectionReference?
    
    weak var databaseController: DatabaseProtocol?
    
    /// Action to pass the date to the next view controller to create reminder
    @IBAction func selectDate(_ sender: Any) {
        if calendarPicker.date < Date() {
            displayMessage(title: "Error", message: "Please enter a valid date")
        } else {
            performSegue(withIdentifier: "createNewSegue", sender: self)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reminderView.delegate = self
        self.reminderView.dataSource = self
        selectButton.tintColor = UIColor(named: "General")
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminderCell = tableView.dequeueReusableCell(withIdentifier: CELL_REMINDER, for: indexPath)
        
        let reminder = reminder[indexPath.row]
        var contentConfiguration = reminderCell.defaultContentConfiguration()
        
        // Configuring the text in the reminder cell
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle:.caption1)
        
        // Configuring the symbol next to the text
        // Symbol represents whether the reminder is complete
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        contentConfiguration.image = image
        contentConfiguration.imageProperties.tintColor = UIColor(named: "General")
        contentConfiguration.imageProperties.maximumSize = CGSize(width: 25, height: 25)
        
        reminderCell.contentConfiguration = contentConfiguration
        return reminderCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reminders"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Delete the reminder entry from database as well
        if editingStyle == .delete {
            databaseController?.deleteReminder(reminder: reminder[indexPath.row])
        }
    }
    
    /// Initialiser to display message using view controller
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // To direct the user to see the details of the reminder
        if segue.identifier == "reminderSegue"{
            if let indexPath = reminderView.indexPathForSelectedRow {
                reminderView.deselectRow(at: indexPath, animated: true)
                let destination = segue.destination as! DetailReminderViewController
                destination.navigationItem.title = reminder[indexPath.row].title
                destination.selectedReminder = reminder[indexPath.row]
            }
        // To direct the user to create a new reminder based on the date selected using the date picker
        } else if segue.identifier == "createNewSegue"{
            let dateSelected = calendarPicker.date
            let destination = segue.destination as? SetReminderViewController
            destination?.datePicked = dateSelected
        }
    }
}

