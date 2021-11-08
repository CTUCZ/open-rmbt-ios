//
//  RMBTHistorySyncModalState.swift
//  RMBT
//
//  Created by Polina on 08.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

// MARK: Default state

class RMBTHistorySyncModalState {
    var dialogTitle: String {
        return .titleDefault
    }
    
    var dialogDescription: String {
        return .descriptionDefault
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
    
    var isSyncResultViewHidden: Bool {
        return true
    }
    
    var isSpinnerViewHidden = true
    
    var syncCode: String? {
        return nil
    }
    
    var syncError: String? {
        return nil
    }
    
    func copyWith(isSpinnerViewHidden: Bool?) -> RMBTHistorySyncModalState {
        self.isSpinnerViewHidden = isSpinnerViewHidden ?? true
        return self
    }
}

// MARK: Entering code state

class RMBTHistorySyncModalStateEnterCode: RMBTHistorySyncModalState {
    override var dialogDescription: String {
        return .descriptionEnterCode
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
    
    override var isSyncResultViewHidden: Bool {
        return true
    }
    
}

// MARK: Requesting code state

class RMBTHistorySyncModalStateRequestCode: RMBTHistorySyncModalState {
    override var dialogDescription: String {
        return .descriptionRequestCode
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
    
    override var isSyncResultViewHidden: Bool {
        return true
    }
    
    override var syncCode: String? {
        return _syncCode
    }
    
    private var _syncCode: String?
    
    init(_ syncCode: String?) {
        _syncCode = syncCode
    }
}

// MARK: Sync success state

class RMBTHistorySyncModalStateSyncSuccess: RMBTHistorySyncModalState {
    override var dialogTitle: String {
        return .titleSyncSuccess
    }
    
    override var dialogDescription: String {
        return .descriptionSyncSuccess
    }

    override var isEnterCodeViewHidden: Bool {
        return true
    }
    
    override var isDefaultButtonsViewHidden: Bool {
        return true
    }
    
    override var isRequestCodeViewHidden: Bool {
        return true
    }
    
    override var isSyncResultViewHidden: Bool {
        return false
    }
}

// MARK: Sync error state

class RMBTHistorySyncModalStateSyncError: RMBTHistorySyncModalState {
    override var dialogDescription: String {
        return .descriptionEnterCode
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
    
    override var isSyncResultViewHidden: Bool {
        return true
    }
    
    override var syncError: String? {
        return _syncError
    }
    
    private var _syncError: String?
    
    init(_ syncError: String?) {
        _syncError = syncError
    }
}

// MARK: Localizations

private extension String {
    static let titleDefault = NSLocalizedString("history.sync-modal-title.default", comment: "")
    static let titleSyncSuccess = NSLocalizedString("history.sync-modal-title.sync-success", comment: "")
    static let descriptionDefault = NSLocalizedString("history.sync-modal-description.default", comment: "")
    static let descriptionEnterCode = NSLocalizedString("history.sync-modal-description.enter-code", comment: "")
    static let descriptionRequestCode = NSLocalizedString("history.sync-modal-description.request-code", comment: "")
    static let descriptionSyncSuccess = NSLocalizedString("history.sync-modal-description.sync-success", comment: "")
}
