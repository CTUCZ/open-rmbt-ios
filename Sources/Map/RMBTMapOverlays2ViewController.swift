//
//  RMBTMapOverlays2ViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

protocol RMBTMapOverlays2ViewControllerDelegate: AnyObject {
    func mapOverlaysViewControllerMapTypeDidChange(_ vc: RMBTMapOverlays2ViewController)
    func mapOverlaysViewControllerOverlayDidChange(_ vc: RMBTMapOverlays2ViewController)
}

class RMBTMapOverlays2ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var hybridTypeLabel: UILabel!
    @IBOutlet weak var hybridTypeButton: UIButton!
    @IBOutlet weak var satelliteTypeLabel: UILabel!
    @IBOutlet weak var satelliteTypeButton: UIButton!
    @IBOutlet weak var standardTypeLabel: UILabel!
    @IBOutlet weak var standardTypeButton: UIButton!
    
    @IBOutlet weak var shapesOverlayLabel: UILabel!
    @IBOutlet weak var shapesOveralyButton: UIButton!
    @IBOutlet weak var pointsOverlayLabel: UILabel!
    @IBOutlet weak var pointsOverlayButton: UIButton!
    @IBOutlet weak var heatmapOverlayLabel: UILabel!
    @IBOutlet weak var heatmapOverlayButton: UIButton!
    var mapOptions: RMBTMapOptions?
    
    weak var delegate: RMBTMapOverlays2ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        standardTypeButton.layer.cornerRadius = 20
        satelliteTypeButton.layer.cornerRadius = 20
        hybridTypeButton.layer.cornerRadius = 20
            
        standardTypeButton.setImage(standardTypeButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        satelliteTypeButton.setImage(satelliteTypeButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        hybridTypeButton.setImage(hybridTypeButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        heatmapOverlayButton.layer.cornerRadius = 20
        pointsOverlayButton.layer.cornerRadius = 20
        shapesOveralyButton.layer.cornerRadius = 20
            
        heatmapOverlayButton.setImage(heatmapOverlayButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        pointsOverlayButton.setImage(pointsOverlayButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        shapesOveralyButton.setImage(shapesOveralyButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.updateMapTypeSelection()
        self.updateOverlaySelection()
    }
    
    func updateMapTypeSelection() {
        standardTypeButton.backgroundColor = .mapTypeUnSelectedBackground
        satelliteTypeButton.backgroundColor = .mapTypeUnSelectedBackground
        hybridTypeButton.backgroundColor = .mapTypeUnSelectedBackground
        
        standardTypeButton.tintColor = .mapTypeUnSelectedTintImage
        satelliteTypeButton.tintColor = .mapTypeUnSelectedTintImage
        hybridTypeButton.tintColor = .mapTypeUnSelectedTintImage
        
        standardTypeLabel.textColor = .mapTypeUnSelectedTitle
        satelliteTypeLabel.textColor = .mapTypeUnSelectedTitle
        hybridTypeLabel.textColor = .mapTypeUnSelectedTitle
        
        switch mapOptions?.oldMapViewType {
        case .standard:
            standardTypeButton.backgroundColor = .mapTypeSelectedBackground
            standardTypeButton.tintColor = .mapTypeSelectedTintImage
            standardTypeLabel.textColor = .mapTypeSelectedTitle
        case .satellite:
            satelliteTypeButton.backgroundColor = .mapTypeSelectedBackground
            satelliteTypeButton.tintColor = .mapTypeSelectedTintImage
            satelliteTypeLabel.textColor = .mapTypeSelectedTitle
        case .hybrid:
            hybridTypeButton.backgroundColor = .mapTypeSelectedBackground
            hybridTypeButton.tintColor = .mapTypeSelectedTintImage
            hybridTypeLabel.textColor = .mapTypeSelectedTitle
        default:
            standardTypeButton.backgroundColor = .mapTypeSelectedBackground
            standardTypeButton.tintColor = .mapTypeSelectedTintImage
            standardTypeLabel.textColor = .mapTypeSelectedTitle
        }
    }
    
    func updateOverlaySelection() {
        heatmapOverlayButton.backgroundColor = .mapTypeUnSelectedBackground
        pointsOverlayButton.backgroundColor = .mapTypeUnSelectedBackground
        shapesOveralyButton.backgroundColor = .mapTypeUnSelectedBackground
        
        heatmapOverlayButton.tintColor = .mapTypeUnSelectedTintImage
        pointsOverlayButton.tintColor = .mapTypeUnSelectedTintImage
        shapesOveralyButton.tintColor = .mapTypeUnSelectedTintImage
        
        heatmapOverlayLabel.textColor = .mapTypeUnSelectedTitle
        pointsOverlayLabel.textColor = .mapTypeUnSelectedTitle
        shapesOverlayLabel.textColor = .mapTypeUnSelectedTitle
        
        switch mapOptions?.oldActiveOverlay {
        case RMBTMapOptionsOverlayHeatmap:
            heatmapOverlayButton.backgroundColor = .mapTypeSelectedBackground
            heatmapOverlayButton.tintColor = .mapTypeSelectedTintImage
            heatmapOverlayLabel.textColor = .mapTypeSelectedTitle
        case RMBTMapOptionsOverlayPoints:
            pointsOverlayButton.backgroundColor = .mapTypeSelectedBackground
            pointsOverlayButton.tintColor = .mapTypeSelectedTintImage
            pointsOverlayLabel.textColor = .mapTypeSelectedTitle
        case RMBTMapOptionsOverlayShapes:
            shapesOveralyButton.backgroundColor = .mapTypeSelectedBackground
            shapesOveralyButton.tintColor = .mapTypeSelectedTintImage
            shapesOverlayLabel.textColor = .mapTypeSelectedTitle
        case RMBTMapOptionsOverlayAuto: break
        default:
            heatmapOverlayButton.backgroundColor = .mapTypeSelectedBackground
            heatmapOverlayButton.tintColor = .mapTypeSelectedTintImage
            heatmapOverlayLabel.textColor = .mapTypeSelectedTitle
        }
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changedMapType(_ sender: UIView) {
        switch sender.tag {
        case 0: mapOptions?.oldMapViewType = .standard
        case 1: mapOptions?.oldMapViewType = .satellite
        case 2: mapOptions?.oldMapViewType = .hybrid
        default: mapOptions?.oldMapViewType = .standard
        }
        
        self.updateMapTypeSelection()
        self.delegate?.mapOverlaysViewControllerMapTypeDidChange(self)
    }
    
    @IBAction func changeMapOverlay(_ sender: UIView) {
        var newOverlay: RMBTMapOptionsOverlay?
        switch sender.tag {
        case 0: newOverlay = RMBTMapOptionsOverlayHeatmap
        case 1: newOverlay = RMBTMapOptionsOverlayPoints
        case 2: newOverlay = RMBTMapOptionsOverlayShapes
        default: newOverlay = RMBTMapOptionsOverlayAuto
        }

        mapOptions?.oldActiveOverlay = newOverlay
        self.updateOverlaySelection()
        self.delegate?.mapOverlaysViewControllerOverlayDidChange(self)
    }
    
}

extension RMBTMapOverlays2ViewController: RMBTBottomCardProtocol {
    var contentSize: CGSize { return CGSize(width: 0, height: 302) }
}

private extension UIColor {
    static let mapTypeSelectedBackground = UIColor(red: 89.0/255.0, green: 178.0/255.0, blue: 0, alpha: 1.0)
    static let mapTypeUnSelectedBackground = UIColor.clear
    
    static let mapTypeSelectedTitle = UIColor(red: 89.0/255.0, green: 178.0/255.0, blue: 0, alpha: 1.0)
    static let mapTypeUnSelectedTitle = UIColor(red: 95.0/255.0, green: 99.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    
    static let mapTypeSelectedTintImage = UIColor.white
    static let mapTypeUnSelectedTintImage = UIColor(red: 95.0/255.0, green: 99.0/255.0, blue: 104.0/255.0, alpha: 1.0)
}
