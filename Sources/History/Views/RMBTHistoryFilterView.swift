//
//  RMBTHistoryFilterView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 05.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryFilterView: UIView {

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    static func view() -> RMBTHistoryFilterView {
        return UINib(nibName: "RMBTHistoryFilterView", bundle: nil).instantiate(withOwner: self, options: nil).first as! RMBTHistoryFilterView
    }
    
    var activeFilters: [String: [String]] = [:] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var onFilterChanged: (_ activeFilters: [String: [String]]) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: RMBTHistoryViewCell.ID, bundle: nil), forCellWithReuseIdentifier: RMBTHistoryViewCell.ID)
        
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
    }
}

extension RMBTHistoryFilterView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return activeFilters.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = Array(activeFilters.keys)[section]
        let filters = activeFilters[key]?.count ?? 0
        return filters
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let key = Array(activeFilters.keys)[indexPath.section]
        let filters = activeFilters[key]?[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTHistoryViewCell.ID, for: indexPath) as! RMBTHistoryViewCell
        cell.titleLabel.text = filters
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = Array(activeFilters.keys)[indexPath.section]
        
        var filters = activeFilters[key]
        filters?.remove(at: indexPath.row)
        activeFilters[key] = filters
        
        collectionView.reloadData()
        onFilterChanged(activeFilters)
    }
}
