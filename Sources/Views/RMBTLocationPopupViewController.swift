//
//  RMBTPopupViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 13.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTLocationPopupViewController: RMBTPopupViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        self.titleLabel.text = .location
        self.collectionView.register(UINib(nibName: RMBTLocationPopupCollectionView.ID, bundle: nil), forCellWithReuseIdentifier: RMBTLocationPopupCollectionView.ID)
        super.viewDidLoad()
    }
    
    static func presentLocation(with info: RMBTPopupInfo, in vc: UIViewController, tickHandler: @escaping (_ vc: RMBTPopupViewController) -> Void = {_ in }) {
        let navController = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "RMBTLocationPopupNavigationController") as! UINavigationController
        guard let popupViewController = navController.topViewController as? RMBTPopupViewController else { return }
        popupViewController.info = info
        popupViewController.onTickHandler = tickHandler
        popupViewController.popupType = .location
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        vc.present(navController, animated: false, completion: nil)
    }
    
    override func contentHeight() -> CGFloat {
        return CGFloat((self.info?.values.count ?? 0) * 32)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.info?.style == .list {
            return CGSize(width: collectionView.bounds.width, height: 32)
        } else {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let value = self.info?.values[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTLocationPopupCollectionView.ID, for: indexPath) as! RMBTLocationPopupCollectionView
        cell.value = value
        return cell
    }
}

private extension String {
    static let location = NSLocalizedString("location_dialog_label_title", comment: "")
}
