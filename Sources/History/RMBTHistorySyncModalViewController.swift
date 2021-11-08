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
    @IBOutlet weak var dialogTitle: UILabel!
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
    @IBOutlet weak var syncSuccessView: UIStackView!
    @IBOutlet weak var syncSuccessCloseButton: UIButton!
    
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
        syncSuccessCloseButton.addTarget(self, action: #selector(closeDialog), for: .touchUpInside)
    }
    
    private func setState(_ state: RMBTHistorySyncModalState) {
        self.state = state
        dialogTitle.text = state.dialogTitle
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
        syncCodeTextField.placeholder = .code
        syncSuccessCloseButton.setTitle(.closeButton, for: .normal)
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

// MARK: Localizations
private extension String {
    static let enterCodeButton = NSLocalizedString("Enter code", comment: "").uppercased()
    static let requestCodeButton = NSLocalizedString("Request code", comment: "").uppercased()
    static let closeButton = NSLocalizedString("Close", comment: "").uppercased()
    static let code = NSLocalizedString("Code", comment: "")
}
