//
//  TrackerReminderViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import UIKit

class TrackerReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, didChangeStatusDelegate {
    
    func changeStatus(chosenReminder: Reminder?) {
        guard let index = reminder.firstIndex(where: { $0.title == chosenReminder?.title }) else {
            return // item not found in the `items` array
        }
        
        reminder[index].isComplete = true
        
        let indexPath = IndexPath(row: index, section: 0)
        reminderView.reloadRows(at: [indexPath], with: .automatic)
    }
    

    @IBOutlet weak var reminderView: UITableView!
    
    var reminder = [Reminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reminderView.delegate = self
        self.reminderView.dataSource = self
        self.navigationItem.largeTitleDisplayMode = .never
        // Do any additional setup after loading the view.
        
        for reminders in Reminder.sampleData {
            reminder.append(reminders)
        }
    }
    


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
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
                destination.delegate = self
            }
        }
    }


}



