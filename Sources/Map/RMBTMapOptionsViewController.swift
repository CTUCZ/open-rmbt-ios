//
//  RMBTMapOptionsViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 19.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

protocol RMBTMapOptionsViewControllerDelegate: AnyObject {
    func mapOptionsViewController(_ vc: RMBTMapOptionsViewController, willDisappearWithChange isChange: Bool)
}

final class RMBTMapOptionsViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var lastSelection: IndexPath?
    
    private var activeSubtypeAtStart: RMBTMapOptionsSubtype?
    private var activeFiltersAtStart: [RMBTMapOptionsFilterValue]?
    private var activeOverlayAtStart: RMBTMapOptionsOverlay?
    
    var constraint: NSLayoutConstraint?
    
    weak var delegate: RMBTMapOptionsViewControllerDelegate?
    
    var mapOptions: RMBTMapOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: RMBTMapOptionsCell.ID, bundle: nil), forCellReuseIdentifier: RMBTMapOptionsCell.ID)
        
        self.navigationController?.delegate = self
        
        self.activeSubtypeAtStart = self.mapOptions?.oldActiveSubtype
        self.activeFiltersAtStart = self.activeFilters()
        self.activeOverlayAtStart = self.mapOptions?.oldActiveOverlay
        
        // TODO: Select overlay
        
//        [self.mapViewTypeSegmentedControl setSelectedSegmentIndex:self.mapOptions.mapViewType];
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let change = (activeOverlayAtStart != self.mapOptions?.oldActiveOverlay) ||
            (activeSubtypeAtStart != self.mapOptions?.oldActiveSubtype) ||
            (self.activeFilters() != activeFiltersAtStart)

        self.delegate?.mapOptionsViewController(self, willDisappearWithChange: change)
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: "presentOptions", sender: self)
    }
 
    private func update(_ cell: RMBTMapOptionsCell, at indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.titleLabel?.text = NSLocalizedString("Map type", comment: "Section title in the map options view")
            let text = String(format: "%@, %@", self.mapOptions?.oldActiveSubtype?.type.title ?? "", self.mapOptions?.oldActiveSubtype?.title ?? "")
            cell.valueLabel?.text = text
            cell.iconImageView?.image = UIImage(named: "map_options_layout")
        } else {
            let f = self.filter(at: indexPath.row)
            cell.titleLabel?.text = f?.title
            cell.valueLabel?.text = f?.activeValue?.title
            cell.iconImageView.image = f?.icon
        }
    }
    
    private func filter(at index: Int) -> RMBTMapOptionsFilter? {
        return self.mapOptions?.oldActiveSubtype?.type.filters[index - 1]
    }
    
    private func activeFilters() -> [RMBTMapOptionsFilterValue]? {
        return self.mapOptions?.oldActiveSubtype?.type.filters.compactMap({ $0.activeValue })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = sender as? IndexPath
        
        lastSelection = indexPath

        if segue.identifier == "show_filter",
           let vc = segue.destination as? RMBTMapOptionsFilterViewController {
            let filter = self.filter(at: indexPath?.row ?? 0)
            vc.filter = filter
        } else if segue.identifier == "show_types",
           let vc = segue.destination as? RMBTMapOptionsTypesViewController {
            vc.mapOptions = self.mapOptions
        }
    }
}

extension RMBTMapOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = (self.mapOptions?.oldActiveSubtype?.type.filters.count ?? 0)
        return count + 1 // type
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTMapOptionsCell.ID, for: indexPath) as! RMBTMapOptionsCell
        self.update(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.performSegue(withIdentifier: "show_types", sender: indexPath)
        } else {
            lastSelection = indexPath
            self.performSegue(withIdentifier: "show_filter", sender: indexPath)
        }
    }

}

extension RMBTMapOptionsViewController: RMBTBottomCardProtocol {
    var contentSize: CGSize { return CGSize(width: 0, height: 400) }
}

extension RMBTMapOptionsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return PushAnimator()
        case .pop: return PopAnimator()
        default: break
        }
        return nil
    }
}
