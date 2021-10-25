//
//  RMBTMapOptionsTypes2ViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTMapOptionsTypes2ViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var mapOptions: RMBTMapOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("Map type", comment: "Title of the map options subview")
        
        self.tableView.register(UINib(nibName: RMBTMapOptionsTypeCell.ID, bundle: nil), forCellReuseIdentifier: RMBTMapOptionsTypeCell.ID)
        
        self.tableView.tintColor = UIColor(red: 89.0/255.0, green: 178.0/255.0, blue: 0.0, alpha: 1.0)
        
        
    }
    
    func subType(at indexPath: IndexPath) -> RMBTMapOptionsSubtype? {
        return self.mapOptions?.oldTypes[indexPath.section].subtypes[indexPath.row]
    }
    
    @IBAction func confirmButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RMBTMapOptionsTypes2ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.mapOptions?.oldTypes.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapOptions?.oldTypes[section].subtypes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subtype = self.subType(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTMapOptionsTypeCell.ID, for: indexPath) as! RMBTMapOptionsTypeCell
        
        cell.titleLabel.text = subtype?.title
        cell.subtitleLabel.text = subtype?.summary
     
        cell.accessoryType = self.mapOptions?.oldActiveSubtype?.identifier == subtype?.identifier ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.mapOptions?.oldTypes[section].title
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mapOptions?.oldActiveSubtype = self.subType(at:indexPath)
        self.tableView.reloadData()
    }
}

extension RMBTMapOptionsTypes2ViewController: RMBTBottomCardProtocol {
    var contentSize: CGSize { return CGSize(width: 0, height: 600) }
}
