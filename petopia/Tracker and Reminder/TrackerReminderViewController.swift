//
//  TrackerReminderViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TrackerReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    func onAllWishlistChange(change: DatabaseChange, wishlist: [Int]) {
        // do nothing
    }
    
 
    var listenerType = ListenerType.reminders
    @IBOutlet weak var calendarPicker: UIDatePicker!
    @IBOutlet weak var reminderView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    
    
    var currentUser = Auth.auth().currentUser
    var reminder = [Reminder]()
    var remindersRef: CollectionReference?

    weak var databaseController: DatabaseProtocol?
    
    @IBAction func selectDate(_ sender: Any) {
        performSegue(withIdentifier: "createNewSegue", sender: self)
        
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        reminder = reminders
        reminderView.reloadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reminderView.delegate = self
        self.reminderView.dataSource = self
        self.navigationItem.largeTitleDisplayMode = .never
        selectButton.tintColor = .systemPink
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController


    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            databaseController?.addListener(listener: self)
            reminderView.reloadData()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            databaseController?.removeListener(listener: self)
            reminderView.reloadData()
        }

                
        let CELL_REMINDER = "reminderCell"
        
        // MARK: - Table view data source
        func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return reminder.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let reminderCell = tableView.dequeueReusableCell(withIdentifier: CELL_REMINDER, for: indexPath)
            
            let reminder = reminder[indexPath.row]
            var contentConfiguration = reminderCell.defaultContentConfiguration()
            
            contentConfiguration.text = reminder.title
            contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
            contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle:.caption1)
            
            let symbolName = reminder.isComplete ? "circle.fill" : "circle"
            let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
            let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
            contentConfiguration.image = image
            contentConfiguration.imageProperties.tintColor = .systemPink
            contentConfiguration.imageProperties.maximumSize = CGSize(width: 25, height: 25)
            
            reminderCell.contentConfiguration = contentConfiguration
            return reminderCell
        }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                        section: Int) -> String? {
            return "Reminders"
        }


        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.deleteReminder(reminder: reminder[indexPath.row])
        }
    }
                
                // MARK: - Navigation
                
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
            
            if segue.identifier == "reminderSegue"{
                if let indexPath = reminderView.indexPathForSelectedRow {
                    reminderView.deselectRow(at: indexPath, animated: true)
                    let destination = segue.destination as! DetailReminderViewController
                    destination.navigationItem.title = reminder[indexPath.row].title
                    destination.selectedReminder = reminder[indexPath.row]
                }
            } else if segue.identifier == "createNewSegue"{
                let dateSelected = calendarPicker.date
                let destination = segue.destination as? setReminderViewController
                destination?.datePicked = dateSelected
            }
        }
            }
            
