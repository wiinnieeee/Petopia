//
//  setReminderViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 9/5/2023.
//

import UIKit
import UserNotifications

class setReminderViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    let dateFormatter = DateFormatter()
    var datePicked: Date?
    weak var databaseController: DatabaseProtocol?
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var notesField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = dateFormatter.string(from: datePicked!)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if (!permissionGranted) {
                print("Permission Denied")
            }
        }
    }
    
    
    @IBAction func addReminder(_ sender: Any) {
        
        guard let title = titleField.text, let notes = notesField.text else {
            return
        }
        let newReminder = Reminder(title: title, dueDate: datePicked!, notes: notes, isComplete: false)
        databaseController?.addReminder(newReminder: newReminder)
        
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
//                    let ac = UIAlertController(title: "Reminder scheduled", message: "At: ", preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
//                    self.present(ac, animated: true)
                    
                    
                } else {
                    
                    let ac = UIAlertController(title: "Enable Notifications", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
