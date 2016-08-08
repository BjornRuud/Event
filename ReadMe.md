# Swift Events

Swift currently lacks an observation mechanism like KVO. KVO can still be used if you make sure your classes use the Objective-C runtime, but that's not very "Swifty". This project is an implementation of the Event pattern, similar to what C# and other languages has. Events can also replace NotificationCenter for app messages (but not system messages).

## Event

Events are defined by the class `Event<T>`. The generic type is the type of the data you want to publish for this event. You then subscribe to the event and provide a handler for doing something with the data.

Here is an example class that publishes an event when a property is set:

```swift
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

foo.valueChanged.subscribe(bar) {
    oldValue, newValue in
    print("Value changed from \(oldValue) to \(newValue)")
}
foo.value = 42
```

## Property

The `Property` class uses `Event` to provide a convenient way to observe value changes. You can create it as a property and then use the `value` property on the `Property` to make value changes.

```swift
class Foo {
    let bar = Property<Int>(0)
}

let foo = Foo()
let ob = SomeClass()
foo.bar.add(observer: ob) {
    oldValue, newValue in
    // Do stuff
}
foo.bar.value = 42
```
