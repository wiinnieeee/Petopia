//
//  ReminderTableView.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import UIKit

class ReminderTableView: UITableView {
    
    var reminder = [Reminder]()

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
           return Reminder.sampleData.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let reminderCell = tableView.dequeueReusableCell(withIdentifier: CELL_REMINDER, for: indexPath)

           let reminder = Reminder.sampleData[indexPath.item]
           var contentConfiguration = reminderCell.defaultContentConfiguration()
           
           contentConfiguration.text = reminder.title
           contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
           contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle:.caption1)
           
           reminderCell.contentConfiguration = contentConfiguration
           return reminderCell
       }


}
