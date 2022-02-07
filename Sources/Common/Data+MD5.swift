//
//  Data+MD5.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {

    func hexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    func MD5() -> Data {
        let hash = self.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(self.count), &hash)
            return hash
        }
        return Data(hash)
    }
}

