//
//  RMBTTestViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 17.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import UIKit

@objc protocol RMBTTestViewControllerDelegate: AnyObject {
    func testViewController(_ controller: RMBTTestViewController, didFinishWithTest result: RMBTHistoryResult?)
}

class RMBTTestViewController: RMBTBaseTestViewController {
    @IBOutlet weak var detailTestView: UIView!
    
    var alertView: UIAlertView?
    var footerLabelTitleAttributes: [String: Any] = [:]
    var footerLabelDetailsAttributes: [String: Any] = [:]

    var qosProgressViewController: RMBTQoSProgressViewController?
    
    @objc weak var delegate: RMBTTestViewControllerDelegate?
    
    // This will hide the network name label in case of cellular connection
    @objc var roaming = false
    
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
    var speedGaugeView: RMBTGaugeView!
    var progressGaugeView: RMBTGaugeView!
    
    var isInfoCollapsed = false
    var isQOSState = false {
        didSet {
            self.counterView.isHidden = !isQOSState
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isQOSState = false
        
        if (self.roaming) {
            self.networkNameLabel.isHidden = true
        }

        self.networkTypeImageView.tintColor = UIColor.white
        self.speedSuffixLabel.text = RMBTSpeedMbpsSuffix()

        self.infoView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.infoView.layer.shadowColor = UIColor.black.cgColor
        self.infoView.layer.shadowOpacity = 0.2
        self.infoView.layer.shadowRadius = 3
        
        self.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoViewTap)))
        
        // Only clear connectivity and location labels once at start to avoid blinking during test restart
        self.networkNameLabel.text = ""
        
        if let label = self.networkTypeLabel {
            self.display(text: "-", for: label)
        }
        if let label = self.footerLocationLabel {
            self.display(text: "-", for: label)
        }

        // Replace placeholder with speed gauges:
        self.progressGaugeView = RMBTGaugeView(frame: self.progressGaugePlaceholderView.frame, name: "progress", startAngle: 214.0, endAngle: 214.0 + 261.0, ovalRect: CGRect(x: 0.0,y: 0,width: 175.0, height: 175.0))
        self.view.insertSubview(progressGaugeView, belowSubview:self.progressLabel)

        self.speedGaugeView = RMBTGaugeView(frame: self.speedGaugePlaceholderView.frame, name: "speed", startAngle: 33.5, endAngle: 299.0, ovalRect: CGRect(x: 0,y: 0,width: 175.0, height: 175.0))
        self.view.insertSubview(speedGaugeView, belowSubview:self.progressLabel)

        self.progressGaugePlaceholderView.isHidden = true
        self.speedGaugePlaceholderView.isHidden = true

        self.view.layoutSubviews()

        self.startTest()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateDetailInfoView()
        self.counterAnimationView.isAnimating = true
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.progressGaugeView.frame = self.progressGaugePlaceholderView.frame
        self.speedGaugeView.frame = self.speedGaugePlaceholderView.frame
    }
    
    @objc func infoViewTap() {
        isInfoCollapsed = !isInfoCollapsed
        self.updateDetailInfoView()
    }
    
    @objc func updateDetailInfoView() {
        if (isInfoCollapsed) {
            UIView.animate(withDuration: 0.3) {
                let height: CGFloat = self.isQOSState ? 267 : 195
                self.detailInfoHeightConstraint.constant = height
                self.bottomSpeedConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                let offset = self.detailInfoHeightConstraint.constant
                self.bottomSpeedConstraint.constant = -(offset + self.view.safeAreaInsets.bottom)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func startTest() {
        self.showQoSUI(false) // in case we're restarting because test was cancelled in qos phase
        
        self.display(text: "-", for: self.pingResultLabel)
        self.display(text: "-", for: self.downResultLabel)
        self.display(text: "-", for: self.upResultLabel)

        self.arrowImageView.image = nil

        speedGaugeView.value = 0.0
        self.speedLabel.text = ""
        self.speedSuffixLabel.isHidden = true
        self.speedGraphView.clear()
        
        super.startTest(withExtraParams: nil)
    }
    
    @objc func showQoSUI(_ state: Bool) {
        self.speedGraphView.isHidden = state;
    //    _speedGaugeView.hidden = state;
        self.speedLabel.isHidden = state;
        self.speedSuffixLabel.isHidden = state;
        self.arrowImageView.isHidden = state;
        self.qosProgressView.isHidden = !state;
    }
    
    // MARK: - Footer
    
    @objc (displayText:forLabel:) func display(text: String, for label: UILabel) {
        label.text = text
    }
    
    func displayAlert(with title: String,
                      message: String,
                      cancelButtonTitle: String? = nil,
                      otherButtonTitle: String? = nil,
                      cancelHandler: @escaping RMBTBlock,
                      otherHandler: @escaping RMBTBlock) {
        if ((alertView) != nil) { alertView?.dismiss(withClickedButtonIndex: -1, animated: false) }
        
        alertView = UIAlertView.bk_alertView(withTitle: title, message: message)
        
        if ((cancelButtonTitle) != nil) { alertView?.bk_setCancelButton(withTitle: cancelButtonTitle, handler: cancelHandler) }
        if ((otherButtonTitle) != nil) { alertView?.bk_addButton(withTitle: otherButtonTitle, handler: otherHandler) }
        alertView?.show()
    }
    
    func updateSpeedLabel(for phase: RMBTTestRunnerPhase, withSpeed kbps: UInt32, isFinal: Bool) {
        self.speedSuffixLabel.isHidden = false
        guard let l = (phase == .down) ? self.downResultLabel : self.upResultLabel else { return }
        self.display(text: RMBTSpeedMbpsStringWithSuffix(kbps, false), for: l)
        self.speedLabel.text = RMBTSpeedMbpsStringWithSuffix(kbps, false)
    }
    
    func hideAlert() {
        if ((alertView) != nil) {
            alertView?.dismiss(withClickedButtonIndex: -1, animated: true)
            alertView = nil
        }
    }

    @IBAction func closeButtonClick(_ sender: Any) {
        self.tapped()
    }
    
    func tapped() {
        self.displayAlert(with: RMBTAppTitle() ?? "",
                          message: NSLocalizedString("Do you really want to abort the running test?", comment: "Abort test alert title"),
                          cancelButtonTitle: NSLocalizedString("Abort Test", comment: "Abort test alert button"),
                          otherButtonTitle: NSLocalizedString("Continue", comment: "Abort test alert button")) { [weak self] in
            self?.cancelTest()
        } otherHandler: { }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "embed_qos_progress" && RMBTSettings.shared.skipQoS) {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embed_qos_progress") {
            qosProgressViewController = segue.destination as? RMBTQoSProgressViewController
        }
    }
}

extension RMBTTestViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let v = RMBTVerticalTransitionController()
        v.reverse = true
        return v
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RMBTVerticalTransitionController()
    }
}

extension RMBTTestViewController: RMBTBaseTestViewControllerSubclass {
    func onTestUpdatedConnectivity(_ connectivity: RMBTConnectivity) {
        self.networkNameLabel.text = RMBTValueOrString(connectivity.networkName, "Unknown") as? String
        if let label = self.networkTypeLabel {
            self.display(text: RMBTValueOrString(connectivity.networkTypeDescription, "n/a") as? String ?? "", for: label)
        }

        if (connectivity.networkType == .cellular) {
            self.networkTypeImageView.image = UIImage(named: "mobile_icon")?.withRenderingMode(.alwaysTemplate)
        } else if (connectivity.networkType == .wiFi) {
            self.networkTypeImageView.image = UIImage(named: "wifi_icon")?.withRenderingMode(.alwaysTemplate)
        } else {
            self.networkTypeImageView.image = nil
        }

        self.technologyValueLabel.text = connectivity.networkTypeDescription
    }
    
    func onTestUpdatedLocation(_ location: CLLocation!) {
        if let label = self.footerLocationLabel {
            self.display(text: location.rmbtFormattedString(), for: label)
        }
    }
    
    func onTestUpdatedServerName(_ name: String!) {
        if let label = footerTestServerLabel {
            self.display(text: name, for: label)
        }
    }
    
    func onTestUpdatedStatus(_ status: String!) {
        self.display(text: status, for: self.statusLabel)
    }
    
    func onTestUpdatedTotalProgress(_ percentage: UInt) {
        self.progressLabel.text = "\(percentage)"
        self.progressGaugeView.value = CGFloat(percentage) / 100.0
    }
    
    func onTestStartedPhase(_ phase: RMBTTestRunnerPhase) {
        if (phase == .down) {
            self.arrowImageView.image = UIImage(named: "download_icon")
        } else if (phase == .up) {
            self.speedGraphView.clear()
            self.speedLabel.text = ""
            self.speedSuffixLabel.isHidden = true
            self.arrowImageView.image = UIImage(named: "upload_icon")
        } else if (phase == .qoS) {
            self.isQOSState = true
            self.isInfoCollapsed = true
            self.updateDetailInfoView()
        }
    }
    
    func onTestFinishedPhase(_ phase: RMBTTestRunnerPhase) { }
    
    func onTestMeasuredLatency(_ nanos: UInt64) {
        self.display(text: RMBTMillisecondsStringWithNanos(nanos, false), for: self.pingResultLabel)
    }
    
    func onTestMeasuredTroughputs(_ throughputs: [Any]!, in phase: RMBTTestRunnerPhase) {
        var kbps = 0
        var l: Double = 0.0

        for t in throughputs as? [RMBTThroughput] ?? [] {
            kbps = Int(t.kilobitsPerSecond())
            l = RMBTSpeedLogValue(Double(kbps))
            self.speedGraphView.addValue(Float(l), atTimeInterval: TimeInterval(t.endNanos / NSEC_PER_SEC))
        }

        if (throughputs.count > 0) {
            // Use last values for momentary display (gauge and label)
            speedGaugeView.value = CGFloat(l)
            self.updateSpeedLabel(for: phase, withSpeed: UInt32(kbps), isFinal: false)
        }
    }
    
    func onTestMeasuredDownloadSpeed(_ kbps: UInt32) {
        self.speedGaugeView.value = 0
        // Speed gauge set to 0, but leave the chart until we have measurements for the upload
        // [self.speedGraphView clear];
        self.updateSpeedLabel(for: .down, withSpeed: kbps, isFinal: true)
    }
    
    func onTestMeasuredUploadSpeed(_ kbps: UInt32) {
        self.updateSpeedLabel(for: .up, withSpeed: kbps, isFinal: true)
    }
    
    func onTestStartedQoS(withGroups groups: [Any]!) {
        self.qosProgressViewController?.testGroups = groups as? [RMBTQoSTestGroup]
        self.counterLabel.text = self.qosProgressViewController?.progressString()
        self.showQoSUI(true)
    }
    
    func onTestUpdatedProgress(_ progress: Float, inQoSGroup group: RMBTQoSTestGroup!) {
        self.qosProgressViewController?.updateProgress(progress, for: group)
        self.counterLabel.text = self.qosProgressViewController?.progressString()
    }
    
    func onTestCompleted(with result: RMBTHistoryResult!, qos qosPerformed: Bool) {
        self.counterLabel.text = self.qosProgressViewController?.progressString()
        self.hideAlert()
        self.delegate?.testViewController(self, didFinishWithTest: result)
    }
    
    func onTestCancelled(with reason: RMBTTestRunnerCancelReason) {
        switch(reason) {
        case .userRequested:
            self.dismiss(animated: true, completion: nil)
        case .mixedConnectivity:
            Log.logger.debug("Test cancelled because of mixed connectivity")
            self.startTest()
        case .noConnection, .errorFetchingTestingParams:
            var message: String = ""
            if (reason == .noConnection) {
                Log.logger.debug("Test cancelled because of connection error")
                message = NSLocalizedString("The connection to the test server was lost. Test aborted.", comment: "Alert view message");
            } else {
                Log.logger.debug("Test cancelled failing to fetch test params")
                message = NSLocalizedString("Couldn't connect to test server.", comment: "Alert view message");
            }
            
            self.displayAlert(with: NSLocalizedString("Connection Error", comment: "Alert view title"),
                              message: message,
                              cancelButtonTitle: NSLocalizedString("Cancel", comment: "Alert view button"),
                              otherButtonTitle: NSLocalizedString("Try Again", comment: "Alert view button")) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            } otherHandler: { [weak self] in
                self?.startTest()
            }

        case .errorSubmittingTestResult:
            Log.logger.debug("Test cancelled failing to submit test results")
            self.displayAlert(with: NSLocalizedString("Error", comment: "Alert view title"),
                              message: NSLocalizedString("Test was completed, but the results couldn't be submitted to the test server.", comment: "Alert view message"),
                              cancelButtonTitle: NSLocalizedString("Dismiss", comment: "Alert view button"),
                              otherButtonTitle: nil) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            } otherHandler: { }
        case .appBackgrounded:
            Log.logger.debug("Test cancelled because app backgrounded")
            self.displayAlert(with: NSLocalizedString("Test aborted", comment: "Alert view title"),
                              message: NSLocalizedString("Test was aborted because the app went into background. Tests can only be performed while the app is running in foreground.", comment: "Alert view message"),
                              cancelButtonTitle: NSLocalizedString("Close", comment: "Alert view button"),
                              otherButtonTitle: NSLocalizedString("Repeat Test", comment: "Alert view button")) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            } otherHandler: { [weak self] in
                self?.startTest()
            }
        }
    }
}
