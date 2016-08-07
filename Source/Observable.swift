//
//  Observable.swift
//  Event
//
//  Created by Bjørn Olav Ruud on 07.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import Foundation

public class Observable<T> {
    public var value: T {
        didSet {
            valueChanged.publish((oldValue: oldValue, newValue: value))
        }
    }

    public typealias ValueChangeType = (oldValue: T, newValue: T)
    let valueChanged = Event<ValueChangeType>()

    public init(initialValue: T) {
        self.value = initialValue
    }

    public func add(observer: AnyObject, queue: OperationQueue? = nil, handler: Event<ValueChangeType>.EventHandler) {
        valueChanged.subscribe(observer, queue: queue, handler: handler)
    }

    public func remove(observer: AnyObject) {
        valueChanged.unsubscribe(observer)
    }
}
