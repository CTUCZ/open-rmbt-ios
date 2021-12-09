/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation

///
@objc open class RMBTThroughput: NSObject {

    ///
    @objc var length: UInt64

    ///
    private var _startNanos: UInt64 // nasty hack to get around endless loop with didSet
    @objc open var startNanos: UInt64 {
        get {
            return _startNanos
        }
        set {
            _startNanos = newValue
            _durationNanos = _endNanos - _startNanos

            assert(_durationNanos >= 0, "Invalid duration")
        }
    }

    ///
    private var _endNanos: UInt64 // nasty hack to get around endless loop with didSet
    @objc open var endNanos: UInt64 {
        get {
            return _endNanos
        }
        set {
            _endNanos = newValue
            _durationNanos = _endNanos - _startNanos

            assert(_durationNanos >= 0, "Invalid duration")
        }
    }

    ///
    private var _durationNanos: UInt64 // nasty hack to get around endless loop with didSet
    @objc open var durationNanos: UInt64 {
        get {
            return _durationNanos
        }
        set {
            _durationNanos = newValue
            _endNanos = _startNanos + _durationNanos

            assert(_durationNanos >= 0, "Invalid duration")
        }
    }

    //

    convenience override init() {
        self.init(length: 0, startNanos: 0, endNanos: 0)
    }

    ///
    @objc init(length: UInt64, startNanos: UInt64, endNanos: UInt64) {
        self.length = length
        self._startNanos = startNanos
        self._endNanos = endNanos

        self._durationNanos = endNanos - startNanos

        assert((endNanos - startNanos) >= 0, "Invalid duration")
    }

    ///
    func containsNanos(_ nanos: UInt64) -> Bool {
        return (_startNanos <= nanos && _endNanos >= nanos)
    }

    ///
    @objc open func kilobitsPerSecond() -> Double {
        if (_durationNanos > 0) {
            return Double(length) * 8.0 / (Double(_durationNanos) * Double(1e-6)) // TODO: improve
        }
        else {
            return 0
        }
    }

    ///
    open override var description: String {
        return String(format: "(%@-%@, %lld bytes, %@)",
                      RMBTHelpers.RMBTSecondsString(with: Int64(_startNanos)),
                      RMBTHelpers.RMBTSecondsString(with: Int64(_endNanos)),
                        length,
                        RMBTSpeedMbpsString(kilobitsPerSecond()))
    }
}
