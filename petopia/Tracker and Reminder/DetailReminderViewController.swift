//
//  DetailReminderViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import UIKit

class DetailReminderViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    var selectedReminder: Reminder?
    
    weak var databaseController: DatabaseProtocol?
    
    /// Mark reminder as done if user has finished it
    @IBAction func doneButton(_ sender: Any) {
        databaseController?.doneReminder(reminder: selectedReminder)
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var notes: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Configure the page
        dateAndTime.text = selectedReminder?.dueDate.dayAndTimeText
        notes.text = selectedReminder?.notes
        doneButton.tintColor = UIColor(named: "General")
        
        // If the reminder is complete
        // Hide the done button
        if selectedReminder?.isComplete ?? false {
            doneButton.isHidden = true
        }
    }
}
