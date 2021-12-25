//
//  RMBTQoSControlConnection.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 18.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

// We use long to be compatible with GCDAsyncSocket tag datatype
enum RMBTQoSControlConnectionState: Int {
    case disconnected
    case disconnecting
    case connecting
    case authenticating
    case authenticated
}

enum RMBTQoSControlConnectionTag: Int {
    case greeting = 1
    case accept
    case token
    case accept2
    case requestTimeout
    case command
}

class RMBTQoSControlConnection: NSObject {
    private(set) var token: String
    
    private lazy var socket: GCDAsyncSocket = {
        return GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
    }()
    
    private var params: RMBTQoSControlConnectionParams
    private var delegateQueue = DispatchQueue(label: "at.rmbt.qos.control.delegate")
    private var commandsQueue = DispatchQueue(label: "at.rmbt.qos.control.commands")
    
    private var currentCommand: String?
    private var currentCommandSuccess: RMBTSuccessBlock?
    private var currentCommandError: RMBTErrorBlock?
    private var currentReadReply: Bool = false
    
    private var state: RMBTQoSControlConnectionState = .disconnected
    
    init(with params: RMBTQoSControlConnectionParams, token: String) {
        self.token = token
        self.params = params
    }
    
    func connect() {
        assert(state == .disconnected)
        
        state = .connecting
        
        do {
            try socket.connect(toHost: params.serverAddress, onPort: UInt16(params.port), withTimeout: RMBTConfig.RMBT_QOS_CC_TIMEOUT_S)
        }
        catch let error {
            state = .disconnected
            if currentCommandError != nil {
                self.done(with: nil, error: error)
            }
        }
    }
    
    
    func sendCommand(_ line: String, readReply: Bool, success: @escaping RMBTSuccessBlock, error: @escaping RMBTErrorBlock) {
        commandsQueue.async { [weak self] in
            guard let self = self else { return }
            self.commandsQueue.suspend()
            
            self.currentCommand = line
            self.currentReadReply = readReply
            self.currentCommandSuccess = success
            self.currentCommandError = error

            // Connected?
            if (self.state == .disconnected) {
                self.connect()
            } else {
                assert(self.state == .authenticated)
                self.transmit()
            }
        }
    }
    
    func close() {
        assert(currentCommand == nil)
        state = .disconnecting
        socket.disconnect()
    }
    
    func done(with result: String?, error: Error?) {
        if let error = error {
            assert(currentCommandError != nil)
            currentCommandError?(error, nil)
        } else {
            assert(currentCommandSuccess != nil)
            currentCommandSuccess?(result)
        }
        currentCommandSuccess = nil
        currentCommandError = nil
        currentCommand = nil
        
        commandsQueue.resume()
    }

    func transmit() {
        assert(currentCommand != nil)
        guard let command = currentCommand else { return }
        self.writeLine(command, with: RMBTQoSControlConnectionTag.command)
        if (currentReadReply) {
            self.readLine(with: RMBTQoSControlConnectionTag.command)
        }
    }
    
    // MARK: - Socket helpers

    func readLine(with tag: RMBTQoSControlConnectionTag) {
        socket.readData(to: "\n".data(using: .ascii), withTimeout: RMBTConfig.RMBT_QOS_CC_TIMEOUT_S, tag: tag.rawValue)
    }
    
    func writeLine(_ line: String, with tag: RMBTQoSControlConnectionTag) {
        //    RMBTLog(@"TX %@", line);
        socket.write(line.appending("\n").data(using: .ascii), withTimeout: RMBTConfig.RMBT_QOS_CC_TIMEOUT_S, tag: tag.rawValue)
    }
}

extension RMBTQoSControlConnection: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        let dictionary = [GCDAsyncSocketManuallyEvaluateTrust: NSNumber(value: true)]
        sock.startTLS(dictionary)
    }
    
//    func socketShouldManually
//
//    - (BOOL)socketShouldManuallyEvaluateTrust:(GCDAsyncSocket *)sock {
//        return YES;
//    }

    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTrustPeer trust: SecTrust) -> Bool {
        return true
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        Log.logger.error("QoS control server disconnected: \(String(describing: err))")
        state = .disconnected
        if currentCommandError != nil {
            self.done(with: nil, error: err)
        }
    }
    
    func socketDidSecure(_ sock: GCDAsyncSocket) {
        self.readLine(with: RMBTQoSControlConnectionTag.greeting)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        guard let tag = RMBTQoSControlConnectionTag(rawValue: tag) else {
            assert(false)
            state = .disconnecting
            socket.disconnect()
            return
        }
        let line = String(data: data, encoding: .ascii)
        //    RMBTLog(@"RX %@", line);
        if tag == .greeting {
            self.readLine(with: RMBTQoSControlConnectionTag.accept)
        } else if (tag == RMBTQoSControlConnectionTag.accept) {
            self.writeLine("TOKEN \(token)", with: RMBTQoSControlConnectionTag.token)
            self.readLine(with: RMBTQoSControlConnectionTag.token)
        } else if (tag == RMBTQoSControlConnectionTag.token) {
            self.readLine(with: RMBTQoSControlConnectionTag.accept2)
        } else if (tag == RMBTQoSControlConnectionTag.accept2) {
            state = RMBTQoSControlConnectionState.authenticated
            self.transmit()
    //        [self writeLine:@"REQUEST CONN TIMEOUT 10000" withTag:RMBTQoSControlConnectionTagRequestTimeout];
    //        [self readLineWithTag:RMBTQoSControlConnectionTagRequestTimeout];
    //    } else if (tag == RMBTQoSControlConnectionTagRequestTimeout) {
    //        [_delegate qosControlConnectionDidStart:self];
        } else if (tag == RMBTQoSControlConnectionTag.command) {
            self.done(with: line, error: nil)
        } else {
            assert(false)
            state = .disconnecting
            socket.disconnect()
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        if (tag == RMBTQoSControlConnectionTag.command.rawValue && !currentReadReply) {
            self.done(with: nil, error: nil)
        }
    }

}
