//
//  RMBTSSLHelper.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 15.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc class RMBTSSLHelper: NSObject {

    @objc(encryptionStringForSSLContext:)
    static func encryptionString(for sslContext: SSLContext) -> String {
        let encryptionProtocol = self.encryptionProtocolString(for: sslContext)
        let encryptionCipher = self.encryptionCipherString(for: sslContext)
        return "\(encryptionProtocol) (\(encryptionCipher))"
    }
    
    static func encryptionProtocolString(for sslContext: SSLContext) -> String {
        var encryptionProtocol: SSLProtocol = .sslProtocolUnknown
        SSLGetNegotiatedProtocolVersion(sslContext, &encryptionProtocol)
        
        switch (encryptionProtocol) {
        case .sslProtocolUnknown: return "No Protocol"
        case .sslProtocol2:       return "SSLv2"
        case .sslProtocol3:       return "SSLv3"
        case .sslProtocol3Only:   return "SSLv3 Only"
        case .tlsProtocol1:       return "TLSv1";
        case .tlsProtocol11:      return "TLSv1.1";
        case .tlsProtocol12:      return "TLSv1.2";
        default:                  return String(format:"%d", encryptionProtocol.rawValue)
        }
    }

    static func encryptionCipherString(for sslContext: SSLContext) -> String {
        var cipher: SSLCipherSuite = .zero
        SSLGetNegotiatedCipher(sslContext, &cipher)

        switch (cipher) {
            case SSL_RSA_WITH_RC4_128_MD5:                return "SSL_RSA_WITH_RC4_128_MD5";
            case SSL_NO_SUCH_CIPHERSUITE:                 return "No Cipher";
        default:                             return String(format: "%X", cipher)
        }
    }
}
