//
//  TrackerTableView.swift
//  petopia
//
//  Created by Winnie Ooi on 27/4/2023.
//

import UIKit

class TrackerTableView: UITableView {
    let CELL_REMINDER = "reminderCell"
    let CELL_REPORT = "reportCell"
    
    let SECTION_REMINDER = 0
    let SECTION_REPORT = 1

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_REMINDER {
            let reminderCell = tableView.dequeueReusableCell(withIdentifier: CELL_REMINDER, for: indexPath)
            var content = reminderCell.defaultContentConfiguration()
            content.text = "Set Reminders"
            reminderCell.contentConfiguration = content
            return reminderCell
        } else {
            let reportCell = tableView.dequeueReusableCell(withIdentifier: CELL_REPORT, for: indexPath)
            var content = reportCell.defaultContentConfiguration()
            content.text = "Generate Monthly Report"
            reportCell.contentConfiguration = content
            return reportCell
        }
    }
    

}
