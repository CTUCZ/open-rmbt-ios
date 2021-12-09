//
//  RMBTHelpers.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import Darwin

@inline(__always) func RMBTValueOrNull(_ value: Any?) -> Any? { return value != nil ? value : NSNull() }
@inline(__always) func RMBTValueOrString(_ value: Any?, _ result: String) -> Any? { return value != nil ? value : result }

class RMBTHelpers: NSObject {
    static let mechTimebaseInfo: mach_timebase_info_data_t = {
        var info: mach_timebase_info_data_t = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        return info
    }()
    
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.usesSignificantDigits = true
        formatter.minimumSignificantDigits = 2
        formatter.maximumSignificantDigits = 2
        return formatter
    }()
    
    static let appName: String = {
        return (Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String) ?? ""
    }()
    
    static let buildInfo: String = {
        guard let info = Bundle.main.infoDictionary else { return "--" }
        let gitBranch = info["GitBranch"] as? String ?? ""
        let gitCommitCount = info["GitCommitCount"] as? String ?? ""
        let gitCommit = info["GitCommit"] as? String ?? ""
        return String(format: "%@-%@-%@", gitBranch, gitCommitCount, gitCommit)
    }()

    static let buildDate: String = {
        guard let info = Bundle.main.infoDictionary else { return "--" }
        return info["BuildDate"] as? String ?? ""
    }()
    
    
    static func RMBTPreferredLanguage() -> String {
        let mostPreferredLanguage = Locale.preferredLanguages.first
        guard let language = mostPreferredLanguage?.components(separatedBy: "-").first?.lowercased()
        else { return "en" }
        return language
    }
    
    // Removes all trailing \n or \r
    @objc static func RMBTChomp(_ string: String) -> String {
        var l = string.count
        while (l > 0) {
            let c = (string as NSString).substring(with: NSRange(location: l - 1, length: 1))
            
            if (!(c == "\r" || c == "\n")) { break }
            l -= 1
        }
        return (string as NSString).substring(to: l)
    }
    
    @objc(RMBTPercent:total:)
    static func RMBTPercent(_ count: Int, _ totalCount: Int) -> UInt {
        var percent = (totalCount == 0) ? 0 : Double(count * 100) / Double(totalCount)
        if percent < 0 { percent = 0 }
        return UInt(round(percent))
    }
    
    @objc static func RMBTTimestamp(with date: Date) -> Int {
        return Int(date.timeIntervalSince1970) * 1000
    }
    
    // Replaces $lang in template with de if current local is german, en otherwise
    static func RMBTLocalize(urlString: String) -> String {
        if urlString.range(of: "$lang") != nil {
            var lang = RMBTHelpers.RMBTPreferredLanguage()
            if (!(lang == "de" || lang == "en")) {
                lang = "en"
            }
            return urlString.replacingOccurrences(of: "$lang", with: lang)
        } else {
            return urlString
        }
    }
    
    // Format a number to two significant digits. See https://trac.rtr.at/iosrtrnetztest/ticket/17
    @objc static func RMBTFormatNumber(_ number: NSNumber) -> String? {
        return formatter.string(from: number)
    }

    // Normalize hexadecimal identifier, i.e. 0:1:c -> 00:01:0c
    @objc static func RMBTReformatHexIdentifier(_ identifier: String) -> String {
        var tmp: [String] = []
        let components = identifier.components(separatedBy: ":")
        for c in components {
            if (c.count == 0) {
                tmp.append("00")
            } else if (c.count == 1) {
                tmp.append("0\(c)")
            } else {
                tmp.append(c)
            }
        }
        return tmp.joined(separator: ":")
    }

    // Returns bundle name from Info.plist (i.e. RTR-NetTest or RTR-Netztest)
    @objc static func RMBTAppTitle() -> String {
        return appName;
    }

    @objc static func RMBTMillisecondsString(with nanos: Int64, withMS: Bool) -> String {
        let ms = NSNumber(value: Double(nanos) * 1.0e-6)
        guard let string = RMBTFormatNumber(ms) else { return ""}
        if (withMS) {
            return "\(string) ms"
        }
        return string
    }

    @objc static func RMBTSecondsString(with nanos: Int64) -> String {
        return String(format: "%f s", Double(nanos) * 1.0e-9)
    }

    @objc static func RMBTCurrentNanos() -> UInt64 {
        var now = mach_absolute_time()
        now *= UInt64(mechTimebaseInfo.numer)
        now /= UInt64(mechTimebaseInfo.denom)
        return now
    }

    // Returns a string containing git commit, branch and commit count from Info.plist fields
    // written by the build script
    @objc static func RMBTBuildInfoString() -> String {
        return buildInfo
    }

    @objc static func RMBTBuildDateString() -> String {
        return buildDate;
    }
}
