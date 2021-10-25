//
//  DTNetworkReachability.swift
//  DTCore
//
//  Created by Sergey Glushchenko on 29.01.2021.
//  Copyright © 2021 SPECURE GmbH
//

import Reachability

@objc public class NetworkReachability: NSObject {
    @objc public enum NetworkReachabilityStatus: Int {
        case unknown
        case notReachability
        case mobile
        case wifi
        
        static func status(with connection: Reachability.Connection) -> NetworkReachabilityStatus {
            switch connection {
            case .cellular:
                return .mobile
            case .unavailable:
                return .notReachability
            case .wifi:
                return .wifi
            default:
                return .unknown
            }
        }
    }
    
    @objc public static let shared = NetworkReachability()
    
    private lazy var reachability: Reachability = {
        guard let reachability = try? Reachability() else { fatalError("Reachability not exist") }
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                self.updateStatus(.wifi)
            } else {
                self.updateStatus(.mobile)
            }
        }
        reachability.whenUnreachable = { _ in
            self.updateStatus(.notReachability)
        }
        
        return reachability
    }()
    
    private var blocks: [(_ status: NetworkReachabilityStatus) -> Void] = []
    
    @objc public var isHaveInternet: Bool {
        return self.isWifi || self.isMobile
    }
    
    @objc public var isWifi: Bool {
        return reachability.connection == .wifi
    }
    
    @objc public var isMobile: Bool {
        return reachability.connection == .cellular
    }
    
    @objc public var status: NetworkReachabilityStatus {
        return NetworkReachabilityStatus.status(with: reachability.connection)
    }
    
    @objc public func startMonitoring() {
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc public func stopMonitoring() {
        reachability.stopNotifier()
    }
    
    @objc public func addReachabilityCallback(_ block: @escaping (_ status: NetworkReachabilityStatus) -> Void) {
        blocks.append(block)
    }
    
    private var timer: Timer?
    
    private func startTimerRestartReachability() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
            self.reachability.stopNotifier()
            self.stopMonitoring()
            self.startMonitoring()
        })
    }
    
    private func updateStatus(_ status: NetworkReachabilityStatus) {
        if status == .notReachability || status == .unknown {
            self.startTimerRestartReachability()
        } else {
            if timer?.isValid == true {
                timer?.invalidate()
                timer = nil
            }
        }
        DispatchQueue.main.async {
            for block in self.blocks {
                block(status)
            }
        }
    }
}
