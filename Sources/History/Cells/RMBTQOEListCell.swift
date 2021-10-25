//
//  RMBTQOEListCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTQOEListCell: UITableViewCell {

    static let ID = "RMBTQOEListCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
        
    var items: [RMBTHistoryQOEResultItem] = [] {
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
        
        tableView.register(UINib(nibName: RMBTQOEItemCell.ID, bundle: nil), forCellReuseIdentifier: RMBTQOEItemCell.ID)
        
    }
}

extension RMBTQOEListCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTQOEItemCell.ID, for: indexPath) as! RMBTQOEItemCell
        cell.item = items[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
}
