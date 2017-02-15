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

    private var eventHandlers = [EventHandlerWrapper<T>]()
    private let lock = NSLock()

    public init() {}

    public func publish(_ data: T) {
        lock.atomic {
            clean()
            for wrapper in eventHandlers {
                if let queue = wrapper.queue {
                    queue.async { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.lock.atomic {
                            wrapper.handler?(data)
                            if wrapper.once {
                                wrapper.destroy()
                            }
                        }
                    }
                }
                else {
                    wrapper.handler?(data)
                    if wrapper.once {
                        wrapper.destroy()
                    }
                }
            }
        }
    }

    public func subscribe(_ target: AnyObject, queue: DispatchQueue? = nil, once: Bool = false, handler: @escaping EventHandler) {
        let wrapper = EventHandlerWrapper(target: target, queue: queue, once: once, handler: handler)
        addEventHandler(wrapper)
    }

    public func subscribeOnce(_ target: AnyObject, queue: DispatchQueue? = nil, handler: @escaping EventHandler) {
        subscribe(target, queue: queue, once: true, handler: handler)
    }

    public func unsubscribe(_ target: AnyObject) {
        lock.atomic {
            clean(target: target)
        }
    }

    private func clean(target: AnyObject? = nil) {
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

    private func addEventHandler(_ handler: EventHandlerWrapper<T>) {
        lock.atomic {
            eventHandlers.append(handler)
        }
    }
}

fileprivate final class EventHandlerWrapper<T> {
    weak var target: AnyObject?
    var queue: DispatchQueue?
    let once: Bool
    var handler: Event<T>.EventHandler?

    init(target: AnyObject, queue: DispatchQueue? = nil, once: Bool, handler: @escaping Event<T>.EventHandler) {
        self.target = target
        self.queue = queue
        self.once = once
        self.handler = handler
    }

    fileprivate func destroy() {
        target = nil
        queue = nil
        handler = nil
    }
}
