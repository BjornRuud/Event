//
//  Event.swift
//  Event
//
//  Created by Bjørn Olav Ruud on 06.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import Foundation

public class Event<T> {
    public typealias EventHandler = (T) -> Void

    var eventHandlers = [EventHandlerWrapper<T>]()
    let accessQueue = DispatchQueue(label: "Event.accessQueue")

    public func publish(_ data: T) {
        let currentQueue = OperationQueue.current ?? OperationQueue.main
        accessQueue.sync {
            clean()
            for wrapper in eventHandlers {
                let queue = wrapper.queue ?? currentQueue
                queue.addOperation {
                    wrapper.handler?(data)
                }
            }

        }
    }

    public func subscribe(_ target: AnyObject, queue: OperationQueue? = nil, handler: EventHandler) {
        let wrapper = EventHandlerWrapper(target: target, queue: queue, handler: handler)
        addEventHandler(wrapper)
    }

    public func unsubscribe(_ target: AnyObject) {
        accessQueue.sync {
            clean(target: target)
        }
    }

    func clean(target: AnyObject? = nil) {
        eventHandlers = eventHandlers.filter {
            if $0.target == nil {
                // Handler has been marked for disposal
                return false
            }
            else if target != nil && $0.target === target {
                // Supplied target should be removed
                return false
            }
            return true
        }
    }

    func addEventHandler(_ handler: EventHandlerWrapper<T>) {
        accessQueue.sync {
            eventHandlers.append(handler)
        }
    }
}

final class EventHandlerWrapper<T> {
    weak var target: AnyObject?
    var queue: OperationQueue?
    var handler: Event<T>.EventHandler?

    init(target: AnyObject, queue: OperationQueue? = nil, handler: Event<T>.EventHandler) {
        self.target = target
        self.queue = queue
        self.handler = handler
    }
}
