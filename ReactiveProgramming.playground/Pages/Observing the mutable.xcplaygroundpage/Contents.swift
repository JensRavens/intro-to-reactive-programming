/*:
 # Reactive Programming without Black Magic
 ## Observing the mutable
 The most basic building block of reactive programming is the Observable<T>. Just like Optional<T> it wraps a value and exposes some useful methods to work with it. While Optional<T> gives you the ability to work with values that might not be there, Observable<T> will allow you to work with values that might not yet there. Let’s implement a simple Observable<T>:
*/
class Observable<T> {
    private var observers = [(T)->Void]()
    
    /// The current value of our observable. Can also be set. Observers will get notified as soon as this value changes.
    var value: T {
        didSet {
            observers.forEach { (observer) in
                observer(value)
            }
        }
    }
    
    /// Initialize the observable with a value.
    init(_ value: T) {
        self.value = value
    }
    
    /// subscribe will call the observer every time `value` does change. It also fires immediately with the current value.
    func subscribe(_ observer: @escaping (T)->Void) {
        observers.append(observer)
        observer(value)
    }
}
/*:
 Observable are reference types. They store a value and notify all subscribed observers of a new value, basically resembling KVO on an object level.
 - Note: In this implementation observables always have a value, just to make the examples a bit easier to read.
 After initializing an observable with a value, you can attach observers to get notified as soon as the contained value changes:
*/
let name = Observable("Tom")
/*:
 The new observable `name` is an `Observable<String>`. The type is automatically infered by Swift and the value can be accessed via it's value property. This property is mutable and can be changed at any time.
*/
name.value
name.value = "Matt"
name.value
//: Observers can subscribe to the changes of values via `subscribe`. For convenience reasons the block is immediately executed with the current value of the observable, therefore this will print out "Matt", then "Claudia".
name.subscribe { newName in
    print(newName)
}
name.value = "Claudia"
//: [Next: A practical example with UIKit](@next)
