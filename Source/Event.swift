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
        clean()
        accessQueue.sync {
            for handler in eventHandlers {
                handler.invoke(data: data)
            }
        }
    }

    public func subscribe(_ target: AnyObject, queue: DispatchQueue? = nil, handler: EventHandler) -> Disposable {
        let wrapper = EventHandlerWrapper(target: target, queue: queue, handler: handler)
        addEventHandler(wrapper)
        return wrapper
    }

    public func unsubscribe(_ target: AnyObject) {
        accessQueue.sync {
            eventHandlers = eventHandlers.filter { $0.target != nil && $0.target !== target }
        }
    }

    func clean() {
        accessQueue.sync {
            eventHandlers = eventHandlers.filter { $0.target != nil }
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
    var queue: DispatchQueue?
    var handler: Event<T>.EventHandler?

    init(target: AnyObject, queue: DispatchQueue? = nil, handler: Event<T>.EventHandler) {
        self.target = target
        self.queue = queue
        self.handler = handler
    }

    func invoke(data: T) {
        guard target != nil else {
            dispose()
            return
        }
        if let queue = queue {
            queue.async {
                self.handler?(data)
            }
        } else {
            handler?(data)
        }
    }
}

public protocol Disposable {
    func dispose()
}

extension EventHandlerWrapper: Disposable {
    func dispose() {
        // Disposing releases held resources but doesn't actually remove the
        // handler wrapper from the handler list until next clean.
        target = nil
        queue = nil
        handler = nil
    }
}
