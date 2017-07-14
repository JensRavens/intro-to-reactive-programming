extension String: Error {
    
}

public class Observable<T> {
    private var observers = [(T)->Void]()
    
    /// The current value of our observable. Can also be set. Observers will get notified as soon as this value changes.
    public var value: T {
        didSet {
            observers.forEach { (observer) in
                observer(value)
            }
        }
    }
    
    /// Initialize the observable with a value.
    public init(_ value: T) {
        self.value = value
    }
    
    /// subscribe will call the observer every time `value` does change. It also fires immediately with the current value.
    public func subscribe(_ observer: @escaping (T)->Void) {
        observers.append(observer)
        observer(value)
    }

    public func map<U>(_ transform: @escaping (T)->U) -> Observable<U> {
        let observable = Observable<U>(transform(value))
        subscribe { (value) in
            observable.value = transform(value)
        }
        return observable
    }

    public func flatMap<U>(_ transform: @escaping (T)->Observable<U>) -> Observable<U> {
        let observable = transform(value)
        subscribe { (value) in
            transform(value).subscribe({ (value) in
                observable.value = value
            })
        }
        return observable
    }
}
