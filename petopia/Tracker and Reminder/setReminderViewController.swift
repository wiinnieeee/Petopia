//
//  setReminderViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 9/5/2023.
//

import UIKit

//protocol didAddReminderDelegate: AnyObject {
//    func addNewReminder (newReminder: Reminder?)
//}

class setReminderViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    let dateFormatter = DateFormatter()
    var datePicked: Date?
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var notesField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.locale = Locale.current
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = dateFormatter.string(from: datePicked!)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addReminder(_ sender: Any) {
        guard let title = titleField.text, let notes = notesField.text else {
            return
        }
        let newReminder = Reminder(title: title, dueDate: datePicked!, notes: notes, isComplete: false)
        databaseController?.addReminder(newReminder: newReminder)
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
