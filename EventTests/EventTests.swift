//
//  EventTests.swift
//  EventTests
//
//  Created by Bjørn Olav Ruud on 06.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import XCTest

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
        let expect = expectation(description: "Value not set.")
        event.subscribe(self) {
            if $0 == 42 {
                expect.fulfill()
            }
        }
        event.publish(42)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPublishTuple() {
        let event = Event<(oldValue: Int, newValue: Int)>()
        let expect = expectation(description: "Value not set.")
        event.subscribe(self) {
            if ($0, $1) == (1, 2) {
                expect.fulfill()
            }
        }
        event.publish((1, 2))
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSubscribe() {
        let event = Event<Int>()
        event.subscribe(self) { _ in return }
        XCTAssertTrue(event.eventHandlers.contains { $0.target === self })
    }

    func testUnsubscribe() {
        let event = Event<Int>()
        event.subscribe(self) { _ in return }
        event.unsubscribe(self)
        XCTAssertFalse(event.eventHandlers.contains { $0.target === self })
    }

    func testDefaultQueue() {
        let event = Event<Int>()
        Thread.current.threadDictionary["ctx"] = "test"
        let expect = self.expectation(description: "Not current queue.")
        event.subscribe(self) { _ in
            if let ctx = Thread.current.threadDictionary["ctx"] as? String, ctx == "test" {
                expect.fulfill()
            }
        }
        event.publish(42)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCustomQueue() {
        let event = Event<Int>()
        let queue = DispatchQueue(label: "testQueue")
        let expect = self.expectation(description: "Not custom queue.")
        event.subscribe(self, queue: queue) { _ in
            dispatchPrecondition(condition: .onQueue(queue))
            expect.fulfill()
        }
        event.publish(42)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPropertyEvent() {
        class Foo {
            let valueChanged = Event<(oldValue: Int, newValue: Int)>()

            var value = 0 {
                didSet {
                    valueChanged.publish((oldValue: oldValue, newValue: value))
                }
            }
        }

        class Bar {}

        let foo = Foo()
        let bar = Bar()

        let expect = expectation(description: "Value not set.")
        foo.valueChanged.subscribe(bar) {
            oldValue, newValue in
            if oldValue == 0 && newValue == 42 {
                expect.fulfill()
            }
        }
        foo.value = 42
        waitForExpectations(timeout: 1, handler: nil)
    }
}
