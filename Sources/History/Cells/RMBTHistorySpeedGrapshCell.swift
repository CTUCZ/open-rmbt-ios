//
//  RMBTHistorySpeedGrapshCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistorySpeedGrapshCell: UITableViewCell {

    static let ID = "RMBTHistorySpeedGrapshCell"
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var graphs: [(title: String, value: NSObject)] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
            updatePosition()
        }
    }
    
    private func updatePosition() {
        pageControl.numberOfPages = graphs.count
        let page = Int(collectionView.contentOffset.x / collectionView.frame.width)
        if pageControl.currentPage != page {
            pageControl.currentPage = Int(page)
            UIView.transition(with: titleLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.titleLabel.text = self.graphs[Int(page)].title
            } completion: { _ in }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: RMBTHistoryGraphCell.ID, bundle: nil), forCellWithReuseIdentifier: RMBTHistoryGraphCell.ID)
        collectionView.register(UINib(nibName: RMBTHistoryPingGraphCell.ID, bundle: nil), forCellWithReuseIdentifier: RMBTHistoryPingGraphCell.ID)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
}

extension RMBTHistorySpeedGrapshCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return graphs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let graph = self.graphs[indexPath.row].value as? RMBTHistorySpeedGraph {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTHistoryGraphCell.ID, for: indexPath) as! RMBTHistoryGraphCell
            cell.graph = graph
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTHistoryPingGraphCell.ID, for: indexPath) as! RMBTHistoryPingGraphCell
            cell.graph = self.graphs[indexPath.row].value as? RMBTHistoryPingGraph
            return cell
        }
    }
}

extension RMBTHistorySpeedGrapshCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePosition()
    }
}
