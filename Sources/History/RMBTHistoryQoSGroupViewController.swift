//
//  RMBTHistoryQoSGroupViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryQoSGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @objc public var result: RMBTHistoryQoSGroupResult?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.result?.name
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.estimatedRowHeight = 140.0;
        self.tableView.rowHeight = UITableView.automaticDimension

        self.tableView.register(UINib(nibName: RMBTHistoryQoSTitledResultCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryQoSTitledResultCell.ID)
        self.tableView.register(UINib(nibName: RMBTHistoryTitleCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryTitleCell.ID)

        
        self.tableView.register(UINib(nibName: "RMBTHistoryQoSSingleResultCell", bundle: nil), forCellReuseIdentifier: "RMBTHistoryQoSSingleResultCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_qos_single_result",
           let result = sender as? RMBTHistoryQoSSingleResult,
           let vc = segue.destination as? RMBTHistoryQoSSingleViewController {
            vc.result = result
            vc.groupResult = self.result
            vc.seqNumber = UInt((self.result?.tests.firstIndex(of: result) ?? 0) + 1)
            navigationItem.backBarButtonItem = UIBarButtonItem()
        }
    }
    
    private func titleForSection(section: Int) -> String? {
        if (section == 0) {
            return NSLocalizedString("Information", comment: "QoS Details section header");
        } else {
            return NSLocalizedString("Tests", comment: "QoS Details section header");
        }
    }
}

extension RMBTHistoryQoSGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 52
        }
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return self.result?.tests.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryQoSTitledResultCell.ID, for: indexPath) as! RMBTHistoryQoSTitledResultCell
            descriptionCell.titleLabel.text = self.titleForSection(section: indexPath.section)
            descriptionCell.descriptionLabel.text = self.result?.about
            descriptionCell.selectionStyle = .none
            return descriptionCell
        } else if indexPath.section == 1 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryTitleCell.ID, for: indexPath) as! RMBTHistoryTitleCell
            titleCell.title = self.titleForSection(section: indexPath.section)
            titleCell.textColor = UIColor.rmbt_color(withRGBHex: 0x424242)
            titleCell.font = UIFont(name: "Roboto-Medium", size: 16)
            titleCell.selectionStyle = .none
            return titleCell
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RMBTHistoryQoSSingleResultCell", for: indexPath) as! RMBTHistoryQoSSingleResultCell
            if let result = self.result?.tests[indexPath.row] {
                cell.set(result: result, sequenceNumber: UInt(indexPath.row + 1))
            }
            return cell;
        }
        return UITableViewCell()
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2) {
            let result = self.result?.tests[indexPath.row]
            self.performSegue(withIdentifier: "show_qos_single_result", sender: result)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
