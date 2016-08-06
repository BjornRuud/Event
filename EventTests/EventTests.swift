//
//  EventTests.swift
//  EventTests
//
//  Created by Bjørn Olav Ruud on 06.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import XCTest
@testable import EventDemo

class EventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEvent() {
        let event = Event<Int>()
        var eventValue = 0
        _ = event.subscribe(self) { eventValue = $0 }
        event.publish(42)
        XCTAssertTrue(eventValue == 42)
    }

    func testPublishTuple() {
        let event = Event<(oldValue: Int, newValue: Int)>()
        var values = (0, 0)
        _ = event.subscribe(self) { values = $0 }
        event.publish((1, 2))
        XCTAssertTrue(values == (1, 2))
    }

    func testSubscribe() {
        let event = Event<Int>()
        _ = event.subscribe(self) { _ in return }
        XCTAssertTrue(event.eventHandlers.contains { $0.target === self })
    }

    func testUnsubscribe() {
        let event = Event<Int>()
        _ = event.subscribe(self) { _ in return }
        event.unsubscribe(self)
        XCTAssertFalse(event.eventHandlers.contains { $0.target === self })
    }

    func testDispose() {
        let event = Event<Int>()
        let disposable = event.subscribe(self) { _ in return }
        disposable.dispose()
        XCTAssertFalse(event.eventHandlers.contains { $0.target === self })
    }

    func testCustomQueue() {
        let event = Event<Int>()
        let eventQueue = DispatchQueue(label: "testCustomQueue")
        eventQueue.setSpecific(key: DispatchSpecificKey<Int>(), value: 1)
        let expect = self.expectation(description: "Not expected dispatch queue.")
        _ = event.subscribe(self, queue: eventQueue) { _ in
            let value = DispatchQueue.getSpecific(key: DispatchSpecificKey<Int>())
            if value == 1 {
                expect.fulfill()
            }
        }
        event.publish(42)
        self.waitForExpectations(timeout: 1, handler: nil)
    }
}
