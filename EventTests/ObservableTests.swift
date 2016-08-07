//
//  ObservableTests.swift
//  Event
//
//  Created by Bjørn Olav Ruud on 07.08.2016.
//  Copyright © 2016 Bjørn Olav Ruud. All rights reserved.
//

import XCTest
@testable import EventDemo

class ObservableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testObservable() {
        class Foo {
            let bar = Observable<Int>(initialValue: 0)
        }

        let expect = expectation(description: "Value not changed")
        let foo = Foo()
        foo.bar.add(observer: self) {
            oldValue, newValue in
            if oldValue == 0 && newValue == 42 {
                expect.fulfill()
            }
        }
        foo.bar.value = 42
        waitForExpectations(timeout: 1, handler: nil)
    }
}
