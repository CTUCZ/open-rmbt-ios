//
//  RMBTHistorySyncModalViewController.swift
//  RMBT
//
//  Created by Polina on 03.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTHistorySyncModalViewController: UIViewController {
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var dialogDescription: UILabel!
    @IBOutlet weak var defaultButtonsView: UIStackView!
    @IBOutlet weak var requestCodeButton: UIButton!
    @IBOutlet weak var enterCodeButton: UIButton!
    @IBOutlet weak var enterCodeView: UIStackView!
    @IBOutlet weak var syncCodeTextField: UITextField!
    @IBOutlet weak var enterCodeConfirmButton: UIButton!
    @IBOutlet weak var requestCodeView: UIStackView!
    @IBOutlet weak var syncCode: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var spinnerView: UIView!
    
    private var state: RMBTHistorySyncModalState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = .black.withAlphaComponent(0.0)
        setState(RMBTHistorySyncModalState())
        setActionHandlers()
        setTexts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setActionHandlers() {
        backgroundView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(closeDialog))
        )
        closeButton.addTarget(self, action: #selector(closeDialog), for: .touchUpInside)
        enterCodeButton.addTarget(self, action: #selector(showEnterCodeView), for: .touchUpInside)
        requestCodeButton.addTarget(self, action: #selector(showRequestCodeView), for: .touchUpInside)
    }
    
    private func setState(_ state: RMBTHistorySyncModalState) {
        self.state = state
        dialogDescription.text = state.dialogDescription
        requestCodeView.isHidden = state.isRequestCodeViewHidden
        syncCode.text = state.syncCode
        enterCodeView.isHidden = state.isEnterCodeViewHidden
        defaultButtonsView.isHidden = state.isDefaultButtonsViewHidden
        spinnerView.isHidden = state.isSpinnerViewHidden
    }
    
    private func setTexts() {
        closeButton.setTitle(.closeButton, for: .normal)
        enterCodeButton.setTitle(.enterCodeButton, for: .normal)
        enterCodeConfirmButton.setTitle(.enterCodeButton, for: .normal)
        requestCodeButton.setTitle(.requestCodeButton, for: .normal)
    }
}

// MARK: Action handlers

extension RMBTHistorySyncModalViewController {
    @objc func closeDialog() {
        self.dismiss(animated: true)
    }
    
    @objc func showEnterCodeView() {
        setState(RMBTHistorySyncModalStateEnterCode())
    }
    
    @objc func showRequestCodeView() {
        if let state = state {
            setState(state.copyWith(isSpinnerViewHidden: false))
        }
        RMBTControlServer.shared.getSyncCode(success: { response in
            guard let code = response.codes?.first?.code else {
                return self.setState(RMBTHistorySyncModalState())
            }
            self.setState(RMBTHistorySyncModalStateRequestCode(code))
        }, error: { error in
            Log.logger.error(error)
            self.setState(RMBTHistorySyncModalState())
        })
    }
}

// MARK: RMBTHistorySyncModalState

class RMBTHistorySyncModalState {
    var dialogDescription: String {
        return .dialogDescriptionDefault
    }

    var isEnterCodeViewHidden: Bool {
        return true
    }
    
    var isDefaultButtonsViewHidden: Bool {
        return false
    }
    
    var isRequestCodeViewHidden: Bool {
        return true
    }
    
    var isSpinnerViewHidden = true
    
    var syncCode: String? {
        return nil
    }
    
    func copyWith(isSpinnerViewHidden: Bool?) -> RMBTHistorySyncModalState {
        self.isSpinnerViewHidden = isSpinnerViewHidden ?? true
        return self
    }
}

class RMBTHistorySyncModalStateEnterCode: RMBTHistorySyncModalState {
    override var dialogDescription: String {
        return .dialogDescriptionEnterCode
    }
    
    override var isEnterCodeViewHidden: Bool {
        return false
    }
    
    override var isDefaultButtonsViewHidden: Bool {
        return true
    }
    
    override var isRequestCodeViewHidden: Bool {
        return true
    }
    
    override var syncCode: String? {
        return nil
    }
    
}

class RMBTHistorySyncModalStateRequestCode: RMBTHistorySyncModalState {
    override var dialogDescription: String {
        return .dialogDescriptionRequestCode
    }
    
    override var isEnterCodeViewHidden: Bool {
        return true
    }
    
    override var isDefaultButtonsViewHidden: Bool {
        return true
    }
    
    override var isRequestCodeViewHidden: Bool {
        return false
    }
    
    override var syncCode: String? {
        return _syncCode
    }
    
    private var _syncCode: String?
    
    init(_ syncCode: String?) {
        self._syncCode = syncCode
    }
}

// MARK: Localizations
private extension String {
    static let dialogDescriptionDefault = NSLocalizedString("history.sync-modal-description.default", comment: "")
    static let dialogDescriptionEnterCode = NSLocalizedString("history.sync-modal-description.enter-code", comment: "")
    static let dialogDescriptionRequestCode = NSLocalizedString("history.sync-modal-description.request-code", comment: "")
    static let enterCodeButton = NSLocalizedString("Enter code", comment: "").uppercased()
    static let requestCodeButton = NSLocalizedString("Request code", comment: "").uppercased()
    static let closeButton = NSLocalizedString("Close", comment: "").uppercased()
}
