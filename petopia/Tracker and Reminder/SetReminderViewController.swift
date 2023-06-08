//
//  SetReminderViewController.swift
//  petopia
//  View for the user to create new reminder and schedule local notifications
//  Reference to local notifications: https://www.youtube.com/watch?v=yOZPm6WQFVk
//
//  Created by Winnie Ooi on 9/5/2023.
//

import UIKit
import UserNotifications

class SetReminderViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    let dateFormatter = DateFormatter()
    var datePicked: Date?
    weak var databaseController: DatabaseProtocol?
    
    // Initialise the use of notification center to push notification for the remiders
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = dateFormatter.string(from: datePicked!)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Request authorisation to send local notifications
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if (!permissionGranted) {
                print("Permission Denied")
            }
        }
    }
    
    /// Create the reminder based on the time, title and the description input in the text field
    @IBAction func addReminder(_ sender: Any) {
        guard let title = titleField.text, let notes = notesField.text else {
            return
        }
        
        // Add the new reminder entry
        let newReminder = Reminder(title: title, dueDate: datePicked!, notes: notes, isComplete: false)
        databaseController?.addReminder(newReminder: newReminder)
        
        // Create a notification trigger and add the request to the notification center
        // To push local notifications
        notificationCenter.getNotificationSettings{(settings) in
            DispatchQueue.main.async {
                let title = self.titleField.text!
                let message = self.notesField.text!
                let date = self.datePicked!
                
                if (settings.authorizationStatus == .authorized) {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    print(dateComp)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) {(error) in
                        if (error != nil) {
                            print("Error" + error.debugDescription)
                            return
                        }
                    }
                } else {
                    // Need the user to authorise local notifications if it's not authorised yet during load
                    // Do this by using Alert Controller
                    let ac = UIAlertController(title: "Enable Notifications", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
                    
                    // Go to settings to enable notifications for the application
                    let goToSettings = UIAlertAction(title: "Settings", style: .default)
                    { (_) in guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
                        else {
                        return
                    }
                        if (UIApplication.shared.canOpenURL(settingsURL)){
                            UIApplication.shared.open(settingsURL) { (_) in }
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
