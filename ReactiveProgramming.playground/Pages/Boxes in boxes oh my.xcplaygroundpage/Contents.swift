/*:
 ## Boxes in boxes, oh my!
 Not every transform can be written in a way that it returns an unboxed value. A transform applied to an optional could return an optional for example:
 */
let name: Optional<String> = "Tom"
func filter(string: String) -> Optional<String> {
    return string.hasPrefix("T") ? name : nil}
let transformed: Optional<Optional<String>> = name.map(filter)
/*:
 This is both annoying and not very practical (apart from the obvious uselesness of this filter function). In the end we would like to have a simple observable - either it's there or not. Meet `flatMap`:
 */
let flatTransformed: Optional<String> = name.flatMap(filter)
/*:
 `flatMap` takes a boxed value, unboxes it, applies the function and puts the result back in the box (and in case the result is boxed as well, it will unwrap that box, too).
 
 And of course we can write something similar for our `Observable<T>` as well. In this case we invoke the transform every time our value changes and then wait until the result is completed:
 */
extension Observable {
    func flatMap<U>(_ transform: @escaping (T)->Observable<U>) -> Observable<U> {
        let observable = transform(value)
        subscribe { (value) in
            transform(value).subscribe({ (value) in
                observable.value = value
            })
        }
        return observable
    }
}
func longComputation(string: String) -> Observable<String?> {
    let observable = Observable<String?>(nil)
    observable.value = string.uppercased() // because we all know uppercasing a string takes time!
    return observable
}
let nameObservable = Observable("Tom")
let transformedNameObservable: Observable<String?> = nameObservable.flatMap(longComputation)
//: - Note: Because the observable always has to have a value in this implementation, we cheat a bit and start with a `nil` value. Other implementations of this patterns handle nil better and allow observables that don't have a value yet.
//:
//: [Next: A slightly more sophisticated use case](@next)
