//
//  RMBTHistoryQoSSingleResultViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 16.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryQoSSingleResultViewController: UITableViewController {

    @IBOutlet weak var statusIconImageView: UIImageView!
    
    public var result: RMBTHistoryQoSSingleResult?
    public var seqNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Test #\(self.seqNumber)"
        self.tableView.estimatedRowHeight = 140.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.statusIconImageView.image = self.result?.statusIcon()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 1
        } else {
            Log.logger.error("Unexpected section index \(section)")
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "details_cell", for: indexPath)
        if (indexPath.section == 0) {
            cell.textLabel?.text = self.result?.statusDetails
        } else {
            cell.textLabel?.text = self.result?.details
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            if(self.result?.successful == true) {
                return NSLocalizedString("Test Succeeded", tableName: "Section header for successful test", comment: "")
            } else {
                return NSLocalizedString("Test Failed", comment: "Section header for successful test")
            }
        } else if (section == 1) {
            return NSLocalizedString("Details", comment: "Section header")
        } else {
            Log.logger.error("Unexpected section index \(section)")
            return nil;
        }
    }
}
