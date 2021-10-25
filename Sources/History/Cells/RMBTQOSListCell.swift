//
//  RMBTQOSListCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTQOSListCell: UITableViewCell {

    static let ID = "RMBTQOSListCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
        
    var onQosSelectHandler: (_ item: RMBTHistoryQoSGroupResult) -> Void = { _ in }
    
    var items: [RMBTHistoryQoSGroupResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: RMBTQOSItemCell.ID, bundle: nil), forCellReuseIdentifier: RMBTQOSItemCell.ID)
    }
}

extension RMBTQOSListCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTQOSItemCell.ID, for: indexPath) as! RMBTQOSItemCell
        cell.item = items[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onQosSelectHandler(items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
