//
//  Lock.swift
//  Event
//
//  Created by Bjørn Olav Ruud on 08.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import Foundation

/// Convenience method to execute a closure atomically
public extension NSLock {
    public func atomic(_ closure: @noescape () -> Void) {
        lock()
        closure()
        unlock()
    }
}
