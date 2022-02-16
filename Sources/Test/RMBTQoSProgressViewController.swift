//
//  RMBTQoSProgressViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTQoSProgressViewController: UITableViewController {

    private var progressForGroupKey: [String: Float] = [:]
    
    var testGroups: [RMBTQoSTestGroup] = [] {
        didSet {
            for g in testGroups {
                progressForGroupKey[g.key] = 0.0
            }
            
            self.tableView.reloadData()
        }
    }
    
    var tests: [RMBTQoSTest] = []
    
    func update(_ progress: Float, for group: RMBTQoSTestGroup) {
        if let index = self.testGroups.firstIndex(of: group) {
            progressForGroupKey[group.key] = progress
            
            let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RMBTQoSProgressCell
            DispatchQueue.main.async {
                cell?.percentView.percents = CGFloat(progress)
            }
        } else {
            assert(false)
        }
    }
    
    func progressString() -> String {
        let total = self.tests.count
        var finished = 0
        for t in self.tests {
            if (t.progress.fractionCompleted == 1.0) {
                finished += 1
            }
        }

        return "\(finished)/\(total)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.clear
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testGroups.count
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let g = testGroups[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "qos_progress_cell", for: indexPath) as? RMBTQoSProgressCell
        cell?.percentView.percents = CGFloat(progressForGroupKey[g.key] ?? 0.0)

        let localizedKey = String(format: "measurement_qos_%@", g.localizedDescription)
        var localized = g.localizedDescription
        if NSLocalizedString(localizedKey, comment: "") != localizedKey {
            localized = NSLocalizedString(localizedKey, comment: "")
        }

        cell?.descriptionLabel.text = localized
        return cell ?? UITableViewCell()
    }

}
