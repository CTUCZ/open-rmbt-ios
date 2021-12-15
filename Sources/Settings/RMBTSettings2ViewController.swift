//
//  RMBTSettings2ViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTSettings2ViewController: UIViewController {

    enum Section {
        case general(_ items: [Item])
        case external
        case contact
        case clientInfo
        case support
    }
    
    enum ItemType {
        case switcher
    }
    
    enum Item {
        case ipv4
        case skipQOS
        case location
        case loopMode
        case loopModeWaitingTime
        case loopModeDistance
        case expertMode
        case website
        case email
        case clientUUID
        case testsCount
        case support
        case sourceCode
        case googleMaps
        case privacy
        case version
        case logo
        
        var type: ItemType {
            switch self {
            case .ipv4:
                return .switcher
            default:
                return .switcher
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [Section] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Settings", comment: "")
        
        self.tableView.register(UINib(nibName: RMBTHistoryTitleCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryTitleCell.ID)
        self.tableView.register(UINib(nibName: RMBTSwitcherCell.ID, bundle: nil), forCellReuseIdentifier: RMBTSwitcherCell.ID)
        
        self.prepareSections()
    }
    
    private func prepareSections() {
        var sections: [Section] = []
        sections.append(.general([.ipv4, .skipQOS, .location, .expertMode]))
        self.sections = sections
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func cell(with item: Item, indexPath: IndexPath) -> UITableViewCell! {
        switch item.type {
        case .switcher:
            let cell = tableView.dequeueReusableCell(withIdentifier: RMBTSwitcherCell.ID, for: indexPath)
            return cell
        @unknown default:
            return UITableViewCell()
        }
    }
    
    private func updateCell(_ cell: UITableViewCell, item: Item) {
        switch item {
        case .ipv4:
            guard let cell = cell as? RMBTSwitcherCell else { return }
            cell.titleLabel.text = "IPv4 Only"
            self.bindSwitch(cell.valueSwitch, toSettingsKeyPath: #keyPath(RMBTSettings.shared.forceIPv4)) { isOn in
                
                if (isOn && RMBTSettings.shared.debugUnlocked && RMBTSettings.shared.debugForceIPv6) {
                    RMBTSettings.shared.debugForceIPv6 = false
                    self.tableView.reloadSections(IndexSet([0]), with: .automatic)
                }
            }
        default: break
            
        }
    }
    
    func bindSwitch(_ aSwitch: UISwitch?, toSettingsKeyPath keyPath: String, onToggle: ((_ value: Bool) -> Void)?) {
        aSwitch?.isOn = (RMBTSettings.shared.value(forKey: keyPath) as! NSNumber).boolValue
        
        guard let theSwitch = aSwitch else { return }
        
        theSwitch.bk_removeEventHandlers(for: .valueChanged)
        theSwitch.bk_addEventHandler({ sender in
            guard let switcher = sender as? UISwitch else { return }
            RMBTSettings.shared.setValue(NSNumber(value: switcher.isOn), forKey: keyPath)
            onToggle?(switcher.isOn)
        }, for: .valueChanged)
    }
}

extension RMBTSettings2ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.sections[indexPath.section]
        switch section {
        case .general(_):
            if indexPath.row == 0 {
                return 48
            }
            return 56
        default: return 56
        }
        
        return 56
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        switch section {
        case .general(let items):
            return items.count + 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        switch section {
        case .general(let items):
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryTitleCell.ID, for: indexPath) as! RMBTHistoryTitleCell
                cell.title = NSLocalizedString("Allgemeine Einstellungen", comment: "")
                return cell
            } else {
                let item = items[indexPath.row - 1]
                if let cell = self.cell(with: item, indexPath: indexPath) {
                    self.updateCell(cell, item: item)
                    return cell
                }
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
}
