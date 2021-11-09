//
//  RMBTHistorySyncModalViewController.swift
//  RMBT
//
//  Created by Polina on 03.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

// MARK: Init

class RMBTHistorySyncModalViewController: UIViewController {
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var dialogHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var dialogDescription: UILabel!
    @IBOutlet weak var defaultButtonsView: UIStackView!
    @IBOutlet weak var requestCodeButton: UIButton!
    @IBOutlet weak var enterCodeButton: UIButton!
    @IBOutlet weak var enterCodeView: UIStackView!
    @IBOutlet weak var syncCodeTextField: RMBTMaterialTextField!
    @IBOutlet weak var enterCodeConfirmButton: UIButton!
    @IBOutlet weak var requestCodeView: UIStackView!
    @IBOutlet weak var syncCode: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var syncResultView: UIStackView!
    @IBOutlet weak var syncResultCloseButton: UIButton!
    
    private var state: RMBTHistorySyncModalState?
    var onSyncSuccess: (() -> Void)?
    
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
    
    private func setState(_ state: RMBTHistorySyncModalState) {
        self.state = state
        dialogTitle.text = state.dialogTitle
        dialogDescription.text = state.dialogDescription
        requestCodeView.isHidden = state.isRequestCodeViewHidden
        syncCode.text = state.syncCode
        enterCodeView.isHidden = state.isEnterCodeViewHidden
        defaultButtonsView.isHidden = state.isDefaultButtonsViewHidden
        spinnerView.isHidden = state.isSpinnerViewHidden
        syncResultView.isHidden = state.isSyncResultViewHidden
        if !state.isEnterCodeViewHidden {
            syncCodeTextField.becomeFirstResponder()
        }
        syncCodeTextField.errorText = state.syncError
        UIView.animate(withDuration: 0.1) {
            self.dialogHeightContraint.constant = state.dialogHeight
        }
    }
    
    private func setTexts() {
        closeButton.setTitle(.closeButton, for: .normal)
        enterCodeButton.setTitle(.enterCodeButton, for: .normal)
        enterCodeConfirmButton.setTitle(.enterCodeButton, for: .normal)
        requestCodeButton.setTitle(.requestCodeButton, for: .normal)
        syncCodeTextField.placeholder = .code
        syncResultCloseButton.setTitle(.closeButton, for: .normal)
    }
}

// MARK: Action handlers

extension RMBTHistorySyncModalViewController {
    private func setActionHandlers() {
        backgroundView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(closeDialog))
        )
        dialogView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDialogTap)))
        closeButton.addTarget(self, action: #selector(closeDialog), for: .touchUpInside)
        enterCodeButton.addTarget(self, action: #selector(showEnterCodeView), for: .touchUpInside)
        enterCodeConfirmButton.addTarget(self, action: #selector(syncWithCode), for: .touchUpInside)
        requestCodeButton.addTarget(self, action: #selector(showRequestCodeView), for: .touchUpInside)
        syncResultCloseButton.addTarget(self, action: #selector(closeDialog), for: .touchUpInside)
    }

    @objc func closeDialog() {
        if state is RMBTHistorySyncModalStateRequestCode {
            self.onSyncSuccess?()
        }
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
    
    @objc func syncWithCode() {
        guard let code = syncCodeTextField.text?.uppercased(), code.count == 12 else {
            return setState(RMBTHistorySyncModalStateSyncError(.codeLengthError))
        }
        if let state = state {
            setState(state.copyWith(isSpinnerViewHidden: false))
        }
        RMBTControlServer.shared.syncWithCode(syncCodeTextField.text?.uppercased() ?? "", success: { response in
            self.setState(RMBTHistorySyncModalStateSyncSuccess())
            self.onSyncSuccess?()
        }, error: { error in
            self.setState(RMBTHistorySyncModalStateSyncError(
                (error as NSError?)?.userInfo["msg_text"] as? String
            ))
        })

    }
    
    @objc func handleDialogTap() {
        syncCodeTextField.resignFirstResponder()
    }
}

// MARK: Localizations

private extension String {
    static let enterCodeButton = NSLocalizedString("Enter code", comment: "").uppercased()
    static let requestCodeButton = NSLocalizedString("Request code", comment: "").uppercased()
    static let closeButton = NSLocalizedString("Close", comment: "").uppercased()
    static let code = NSLocalizedString("Code", comment: "")
    static let codeLengthError = NSLocalizedString("The code must consist of twelve characters", comment: "")
}
