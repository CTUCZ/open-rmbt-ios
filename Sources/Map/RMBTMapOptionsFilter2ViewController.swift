//
//  RMBTMapOptionsFilter2ViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTMapOptionsFilter2ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var filter: RMBTMapOptionsFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: RMBTMapOptionsFilterCell.ID, bundle: nil), forCellReuseIdentifier: RMBTMapOptionsFilterCell.ID)
        self.titleLabel.text = self.filter?.title
        
        self.tableView.tintColor = UIColor(red: 89.0/255.0, green: 178.0/255.0, blue: 0.0, alpha: 1.0)
        
        self.confirmButton.setTitle("ÜBERNEHMEN", for: .normal)
    }
    
    @IBAction func confirmButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RMBTMapOptionsFilter2ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filter?.possibleValues.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTMapOptionsFilterCell.ID, for: indexPath) as! RMBTMapOptionsFilterCell
        let value: RMBTMapOptionsFilterValue? = self.filter?.possibleValues[indexPath.row]
        
        cell.titleLabel?.text = value?.title
        cell.accessoryType = self.filter?.activeValue == value ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newValue = self.filter?.possibleValues[indexPath.row]
        self.filter?.activeValue = newValue
        self.tableView.reloadData()
    }
}
