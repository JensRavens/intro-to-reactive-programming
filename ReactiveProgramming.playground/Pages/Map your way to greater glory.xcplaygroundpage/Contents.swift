/*:
 ## Map your way to greater glory
 Binding things to each other might be useful, but often you will want to transform values on the way. Imagine a document picker that exposes an `Observable<URL>` that you would like to display in a view that takes a `MyDocument` instead.
 
 Transforming the value inside of a container type is called *mapping*. Take the value inside of the box, apply a function, put it back in the box. The simplest version of this can be seen in `Array<T>`:
 */
let names = ["Tom", "Matt", "Claudia"]
let uppsercaseNames = names.map { name in name.uppercased() }
//: This will apply the block to every single value inside of the array and put it into a new array. The same also works with `Optional<T>`:
let name: Optional<String> = "Tom"
let greetedName = name.map { name in "Hello \(name)" }
/*: 
 Map on optionals will take the value of the optional, apply the function and return a new optional. If the optional was empty, the function is not applied and `nil` is returned instead.
 
 Because this concept is so common, container types that implement this feature have a name - *applicatives*.
 
 Wouldnt it be useful to transform our values inside of `Observable<T>` every time it changes? Let's implement `map`:
*/
extension Observable {
    func map<U>(_ transform: @escaping (T)->U) -> Observable<U> {
        let observable = Observable<U>(transform(value))
        subscribe { (value) in
            observable.value = transform(value)
        }
        return observable
    }
}
/*:
 Map will return a new `Observable<U>` (where `U` means, that the transform can change the type of the value, e.g. filepath to `NSData`). Whenever the original observable is updated, the new observable will be updated with the transformed value.
 */
let nameObservable = Observable("Tom")
let greetedNameObservable = nameObservable.map { name in "Hello \(name)" }
greetedNameObservable.value
nameObservable.value = "World"
greetedNameObservable.value // did you really think you wouldn't see a hello world today? 🙃
//: [Next: Boxes in boxes, oh my!](@next)
