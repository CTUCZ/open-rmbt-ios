//
//  UserDefaults+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

extension UserDefaults {
    enum Keys: String {
        case TOSPreferenceKey = "tos_version"
        case lastNewsUidPreferenceKey = "last_news_uid"
    }
    
    ///
    open class func storeTOSVersion(lastAcceptedVersion: Int) {
        storeDataFor(key: Keys.TOSPreferenceKey.rawValue, obj: lastAcceptedVersion)
    }
    
    ///
    open class func getTOSVersion() -> Int {
        return UserDefaults.standard.integer(forKey: Keys.TOSPreferenceKey.rawValue)
    }
    
    ///
    open class func storeLastNewsUidPreference(lastNewsUidPreference: Int) {
        storeDataFor(key: Keys.lastNewsUidPreferenceKey.rawValue, obj: lastNewsUidPreference)
    }
    
    ///
    open class func lastNewsUidPreference() -> Int {
        return UserDefaults.standard.integer(forKey: Keys.lastNewsUidPreferenceKey.rawValue)
    }
    
    /// Generic function
    open class func storeDataFor(key: String, obj: Any) {
    
        UserDefaults.standard.set(obj, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    ///
    open class func getDataFor(key: String) -> Any? {
    
        guard let result = UserDefaults.standard.object(forKey: key) else {
            return nil
        }
        
        return result
    }
    
    open class func storeRequestUserAgent() {
    
        guard let info = Bundle.main.infoDictionary,
            let bundleName = (info["CFBundleName"] as? String)?.replacingOccurrences(of: " ", with: ""),
            let bundleVersion = info["CFBundleShortVersionString"] as? String
        else { return }
        
        let iosVersion = UIDevice.current.systemVersion
        
        let lang = PREFFERED_LANGUAGE
        var locale = Locale.canonicalLanguageIdentifier(from: lang)
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
            locale += "-\(countryCode)"
        }
        
        // set global user agent
        let specureUserAgent = "SpecureNetTest/2.0 (iOS; \(locale); \(iosVersion)) \(bundleName)/\(bundleVersion)"
        UserDefaults.standard.set(specureUserAgent, forKey: "UserAgent")
        UserDefaults.standard.synchronize()
        
        Log.logger.info("USER AGENT: \(specureUserAgent)")
    }
    
    ///
    open class func getRequestUserAgent() -> String? {
        guard let user = UserDefaults.standard.string(forKey: "UserAgent") else {
            return nil
        }
        
        return user
    }
    
    open class func clearStoredUUID(uuidKey: String?) {
        if let uuidKey = uuidKey {
            UserDefaults.standard.removeObject(forKey: uuidKey)
            UserDefaults.standard.synchronize()
        }
    }
    ///
    open class func storeNewUUID(uuidKey: String, uuid: String) {
        if RMBTSettings.shared.isClientPersistent {
            storeDataFor(key: uuidKey, obj: uuid)
            Log.logger.debug("UUID: uuid is now: \(uuid) for key '\(uuidKey)'")
        }
    }
    
    ///
    open class func checkStoredUUID(uuidKey: String) -> String? {
        return UserDefaults.standard.object(forKey: uuidKey) as? String
    }
}
