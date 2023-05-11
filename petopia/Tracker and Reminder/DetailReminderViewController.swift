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
        
        // Do any additional setup after loading the view.
        dateAndTime.text = selectedReminder?.dueDate.dayAndTimeText
        notes.text = selectedReminder?.notes
        doneButton.tintColor = .systemPink
        
        if selectedReminder?.isComplete ?? false {
            doneButton.isHidden = true
        }
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
