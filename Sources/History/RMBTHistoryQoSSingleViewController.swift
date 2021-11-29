//
//  RMBTHistoryQoSSingleViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryQoSSingleViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    public var result: RMBTHistoryQoSSingleResult?
    public var seqNumber: UInt = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Test #\(seqNumber)"
        
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.estimatedRowHeight = 140.0;
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()

        self.tableView.register(UINib(nibName: RMBTHistoryQoSGroupResultCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryQoSGroupResultCell.ID)
    }
    
    private func titleForSection(section: Int) -> String? {
        if (section == 0) {
            if (self.result?.successful == true) {
                return NSLocalizedString("Test Succeeded", comment: "Section header for successful test");
            } else {
                return NSLocalizedString("Test Failed", comment: "Section header for successful test");
            }
        } else if (section == 1) {
            return NSLocalizedString("Details", comment: "Section header");
        } else {
            return nil
        }
    }
}

extension RMBTHistoryQoSSingleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryQoSGroupResultCell.ID, for: indexPath) as! RMBTHistoryQoSGroupResultCell
        descriptionCell.titleLabel.text = self.titleForSection(section: indexPath.section)
        if (indexPath.section == 0) {
            descriptionCell.descriptionLabel?.text = self.result?.statusDetails
        } else {
            descriptionCell.descriptionLabel?.text = self.result?.details
        }
        return descriptionCell
    }
}
