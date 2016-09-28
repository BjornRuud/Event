//
//  Event.swift
//  Event
//
//  Created by Bjørn Olav Ruud on 06.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import Foundation

/// Convenience protocol used when an event needs to support different types.
public protocol EventType {
}

public class Event<T> {
    public typealias EventHandler = (T) -> Void

    var eventHandlers = [EventHandlerWrapper<T>]()
    let lock = NSLock()

    public init() {}

    public func publish(_ data: T) {
        lock.atomic {
            clean()
            for wrapper in eventHandlers {
                if let queue = wrapper.queue {
                    queue.async {
                        wrapper.handler?(data)
                    }
                }
                else {
                    wrapper.handler?(data)
                }
            }
        }
    }

    public func subscribe(_ target: AnyObject, queue: DispatchQueue? = nil, handler: @escaping EventHandler) {
        let wrapper = EventHandlerWrapper(target: target, queue: queue, handler: handler)
        addEventHandler(wrapper)
    }

    public func unsubscribe(_ target: AnyObject) {
        lock.atomic {
            clean(target: target)
        }
    }

    func clean(target: AnyObject? = nil) {
        eventHandlers = eventHandlers.filter {
            if $0.target == nil {
                // Handler has been marked for disposal
                return false
            }
            else if $0.target === target {
                // Supplied target should be removed
                return false
            }
            return true
        }
    }

    func addEventHandler(_ handler: EventHandlerWrapper<T>) {
        lock.atomic {
            eventHandlers.append(handler)
        }
    }
}

final class EventHandlerWrapper<T> {
    weak var target: AnyObject?
    var queue: DispatchQueue?
    var handler: Event<T>.EventHandler?

    init(target: AnyObject, queue: DispatchQueue? = nil, handler: @escaping Event<T>.EventHandler) {
        self.target = target
        self.queue = queue
        self.handler = handler
    }
}
