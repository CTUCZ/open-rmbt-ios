//
//  RMBTMapMeasurementCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 29.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTMapMeasurementCell: UICollectionViewCell {

    static let ID = "RMBTMapMeasurementCell"
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet weak var networkTypeImageView: UIImageView!
    @IBOutlet weak var uploadValueLabel: UILabel!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var pingValueLabel: UILabel!
    @IBOutlet weak var pingImageView: UIImageView!
    @IBOutlet weak var downloadValueLabel: UILabel!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    @IBOutlet weak var networkDetailsStackView: UIStackView!
    
    public var onCloseHandler: () -> Void = {}
    public var onDetailsHandler: () -> Void = {}
    
    var networkType: RMBTNetworkType = .unknown {
        didSet {
            self.updateNetworkType()
        }
    }
    
    var networkDetailList: [SpeedMeasurementResultResponse.ResultItem] = [] {
        didSet {
            if let _ = self.networkDetailList.first(where: { item in
                return item.value == "WLAN" // We can check title, but could be localizated
            }) {
                self.networkType = .wifi
            } else {
                self.networkType = .cellular
            }
            self.updateNetworkDetails()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rootView.layer.shadowOpacity = 0.2
        rootView.layer.shadowOffset = CGSize(width: 0, height: 1)
        rootView.layer.shadowRadius = 3
    }

    @IBAction func closeButtonClick(_ sender: Any) {
        self.onCloseHandler()
    }
    
    @IBAction func detailsButtonClick(_ sender: Any) {
        self.onDetailsHandler()
    }
    
    private func updateNetworkType() {
        if networkType == .wifi {
            self.networkTypeImageView.image = UIImage(named:"wifi_icon")?.withRenderingMode(.alwaysTemplate)
        } else {
            self.networkTypeImageView.image = UIImage(named:"mobile_icon")?.withRenderingMode(.alwaysTemplate)
        }
        self.networkTypeImageView.tintColor = UIColor(red: 95.0 / 255.0, green: 99.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0)
    }
    
    private func updateNetworkDetails() {
        self.networkDetailsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for item in networkDetailList {
            let view = self.viewForNetworkDetails(with: item)
            self.networkDetailsStackView.addArrangedSubview(view)
        }
    }
    
    private func viewForNetworkDetails(with item: SpeedMeasurementResultResponse.ResultItem) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.roboto(size: 14, weight: .regular)
        titleLabel.text = item.title
        
        view.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.roboto(size: 14, weight: .regular)
        valueLabel.textAlignment = .right
        valueLabel.text = item.value
        
        view.addSubview(valueLabel)
        valueLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        valueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        valueLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 5).isActive = true
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return view
    }
}
