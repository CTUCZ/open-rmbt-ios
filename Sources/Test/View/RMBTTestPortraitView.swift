//
//  RMBTTestPortraitView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 15.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTTestPortraitView: UIView, XibLoadable {
    
    @IBOutlet weak var detailTestView: UIView!
    
    @IBOutlet weak var rootGaugeView: UIView!
    @IBOutlet weak var infoTitleView: UIView!
    @IBOutlet weak var loopModeTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loopModeCounterLoaderView: RMBTLoaderView!
    @IBOutlet weak var loopModeCounterLabel: UILabel!
    @IBOutlet weak var loopModeCounterView: UIView!
    @IBOutlet weak var loopModeTitleLabel: UILabel!
    @IBOutlet weak var loopModeTitleView: UIView!
    
    @IBOutlet weak var offsetGaugesConstraint: NSLayoutConstraint!
    @IBOutlet weak var aspectGaugesConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoTitleHeightConstraint: NSLayoutConstraint!

    // Network name and type
    @IBOutlet weak var technologyTitleLabel: UILabel!
    @IBOutlet weak var technologyValueLabel: UILabel!
    @IBOutlet weak var networkTypeLabel: UILabel?
    @IBOutlet weak var networkNameLabel: UILabel!
    @IBOutlet weak var networkTypeImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bottomSpeedConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var counterAnimationView: RMBTLoaderView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counterView: UIView!
    // Progress
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressGaugePlaceholderView: UIImageView!

    // Results
    @IBOutlet weak var pingResultLabel: UILabel!
    @IBOutlet weak var downResultLabel: UILabel!
    @IBOutlet weak var upResultLabel: UILabel!

    // Speed chart
    @IBOutlet weak var speedGaugePlaceholderView: UIImageView!
    @IBOutlet weak var speedGraphView: RMBTSpeedGraphView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSuffixLabel: UILabel!

    // Footer
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var footerTestServerLabel: UILabel?
    @IBOutlet weak var footerLocalIpLabel: UILabel?
    @IBOutlet weak var footerLocationLabel: UILabel?
    
    // QoS
    @IBOutlet weak var qosProgressView: UIView!

    // Loop Mode Waiting
    @IBOutlet weak var loopModeWaitingView: UIView!
    
    // Layout constraints
    @IBOutlet weak var networkSymbolTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkSymbolLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkNameWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var testServerLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var speedGraphBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressGaugeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailInfoHeightConstraint: NSLayoutConstraint!
    
    // Views
    lazy var speedGaugeView: RMBTGaugeView = {
        return RMBTGaugeView(frame: self.speedGaugePlaceholderView.frame, name: "speed", startAngle: 33.5, endAngle: 299.0, ovalRect: CGRect(x: 0,y: 0,width: 175.0, height: 175.0))
    }()
    
    lazy var progressGaugeView: RMBTGaugeView = {
        return RMBTGaugeView(frame: self.progressGaugePlaceholderView.frame, name: "progress", startAngle: 214.0, endAngle: 214.0 + 261.0, ovalRect: CGRect(x: 0.0,y: 0,width: 175.0, height: 175.0))
    }()
    
    var networkName: String? {
        didSet {
            self.networkNameLabel.text = networkName
        }
    }
    
    var networkType: String? {
        didSet {
            self.networkTypeLabel?.text = networkType
        }
    }
    
    var networkTypeImage: UIImage? {
        didSet {
            self.networkTypeImageView.image = networkTypeImage
        }
    }
    
    var technology: String? {
        didSet {
            self.technologyValueLabel.text = technology
        }
    }
    
    var status: String? {
        didSet {
            self.statusLabel.text = status
        }
    }
    
    var progress: UInt = 0 {
        didSet {
            self.progressLabel.text = "\(progress)"
            self.progressGaugeView.value = CGFloat(progress) / 100.0
        }
    }
    
    var speed: UInt32 = 0 {
        didSet {
            self.speedLabel.text = RMBTSpeedMbpsStringWithSuffix(speed, false)
        }
    }
    
    var speedGauge: Double = 0 {
        didSet {
            self.speedGaugeView.value = speedGauge
        }
    }
    
    var ping: String? {
        didSet {
            self.pingResultLabel.text = ping
        }
    }
    
    var down: String? {
        didSet {
            self.downResultLabel.text = down
        }
    }
    
    var up: String? {
        didSet {
            self.upResultLabel.text = up
        }
    }
    
    var isLoopMode: Bool = false {
        didSet {
            updateInfoTitleView()
        }
    }
    
    var onCloseHandler: () -> Void = {}
    
    var isInfoCollapsed = true {
        didSet {
            updateDetailInfoView()
        }
    }
    
    var isQOSState = false {
        didSet {
            self.counterView.isHidden = !isQOSState
        }
    }
    
    var currentTest: UInt = 0 {
        didSet {
            updateInfoTitleView()
        }
    }
    
    var totalTests: UInt = 0 {
        didSet {
            updateInfoTitleView()
        }
    }
    
    var phase: RMBTTestRunnerPhase = .none {
        didSet {
            updatePhase()
        }
    }
    
    var isShowSpeedSuffix: Bool = false {
        didSet {
            self.speedSuffixLabel.isHidden = isShowSpeedSuffix
        }
    }
    
    var qosCounterText: String? {
        didSet {
            self.counterLabel.text = qosCounterText
        }
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        onCloseHandler()
    }
    
    func startAnimation() {
        self.loopModeCounterLoaderView.isAnimating = true
        self.counterAnimationView.isAnimating = true
    }
    
    @objc func showQoSUI(_ state: Bool) {
        self.speedGraphView.isHidden = state
    //    _speedGaugeView.hidden = state;
        self.speedLabel.isHidden = state;
        self.speedSuffixLabel.isHidden = state;
        self.arrowImageView.isHidden = state;
        self.qosProgressView.isHidden = !state;
    }
    
    @objc func showWaitingUI() {
        self.loopModeWaitingView.isHidden = false
        self.speedGraphView.isHidden = true
        self.qosProgressView.isHidden = true
    }
    
    func setQosView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.qosProgressView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.qosProgressView.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.qosProgressView.rightAnchor),
            view.topAnchor.constraint(equalTo: self.qosProgressView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.qosProgressView.bottomAnchor),
        ])
    }
    
    func setWaitingView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.loopModeWaitingView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.loopModeWaitingView.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.loopModeWaitingView.rightAnchor),
            view.topAnchor.constraint(equalTo: self.loopModeWaitingView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.loopModeWaitingView.bottomAnchor),
        ])
    }
    
    func clearValues() {
        self.showQoSUI(false) // in case we're restarting because test was cancelled in qos phase
        loopModeWaitingView.isHidden = true
        
        self.ping = "-"
        self.down = "-"
        self.up = "-"

        self.arrowImageView.image = nil

        speedGaugeView.value = 0.0
        self.speedLabel.text = ""
        self.speedSuffixLabel.isHidden = true
        self.speedGraphView.clear()
        
        self.updateInfoTitleView()
    }
    
    func updateInfoTitleView() {
        infoTitleHeightConstraint.constant = !isLoopMode ? 63 : 111
        loopModeTitleHeightConstraint.constant = !isLoopMode ? 0 : 48
        loopModeTitleView.isHidden = !isLoopMode
        loopModeTitleLabel.text = .loopMode
        loopModeCounterLabel.text = "\(currentTest)/\(totalTests)"
    }
    
    @objc func updateDetailInfoView() {
        if (isInfoCollapsed) {
            UIView.animate(withDuration: 0.3) {
                let height: CGFloat = self.isQOSState ? 267 : 195
                self.detailInfoHeightConstraint.constant = height
                self.bottomSpeedConstraint.constant = 0
                self.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                let offset = self.detailInfoHeightConstraint.constant
                self.bottomSpeedConstraint.constant = -(offset + self.safeAreaInsets.bottom)
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc func infoViewTap() {
        isInfoCollapsed = !isInfoCollapsed
    }
    
    func clearSpeedGraph() {
        self.speedGraphView.clear()
    }
    
    func addSpeed(_ value: CGFloat, at timeinterval: TimeInterval) {
        self.speedGraphView.add(value: value, at: timeinterval)
    }
    
    func updatePhase() {
        if (phase == .down) {
            self.arrowImageView.image = UIImage(named: "download_icon")
        } else if (phase == .up) {
            self.speedGraphView.clear()
            self.speedLabel.text = ""
            self.speedSuffixLabel.isHidden = true
            self.arrowImageView.image = UIImage(named: "upload_icon")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.insertSubview(progressGaugeView, belowSubview:self.progressLabel)
        self.insertSubview(speedGaugeView, belowSubview:self.progressLabel)
        
        self.progressGaugePlaceholderView.isHidden = true
        self.speedGaugePlaceholderView.isHidden = true
        
        self.updateDetailInfoView()
        
        self.infoTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoViewTap)))
        
        self.infoView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.infoView.layer.shadowColor = UIColor.black.cgColor
        self.infoView.layer.shadowOpacity = 0.2
        self.infoView.layer.shadowRadius = 3
    }
    
    func updateGaugesPosition() {
        let originalOffsetScreenWidth: CGFloat = 375
        let originalOffsetConstraint: CGFloat = -85
        let offsetAspect = self.frame.width / originalOffsetScreenWidth
        self.offsetGaugesConstraint.constant = originalOffsetConstraint * offsetAspect
        
        let originalScreenWidth: CGFloat = 375
        let originalConstraint: CGFloat = -39
        let aspect = originalScreenWidth / self.frame.width
        self.aspectGaugesConstraint.constant = originalConstraint * aspect
        self.progressGaugeView.frame = self.progressGaugePlaceholderView.frame
        self.speedGaugeView.frame = self.speedGaugePlaceholderView.frame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateGaugesPosition()
    }
}

private extension String {
    static let loopMode = NSLocalizedString("title_loop_mode", comment: "")
}

