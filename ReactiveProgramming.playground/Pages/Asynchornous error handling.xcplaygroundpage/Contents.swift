/*:
 ## Asynchornous error handling
 So far we have used `nil` to handle errors, but wouldn't it be better to actually know what went wrong? Thinking in boxes can be so much fun, so let's add another container object:
 */
enum Result<T> {
    case Success(T)
    case Error(Error)
}
//: Now we can define our network request like this:
import Foundation

struct Zen {
    let text: String
}

func requestZen(id: Int) -> Observable<Result<Zen>> {
    let observable = Observable<Result<Zen>>(.Error("not yet loaded"))
    DispatchQueue.global().async {
        let data = NSData(contentsOf: URL(string: "https://api.github.com/zen")!) as Data?
        let string = data.flatMap { String(data: $0, encoding: .utf8) }
        let result: Result<Zen> = string.map { .Success(Zen(text: $0)) } ?? .Error("could not load zen")
        DispatchQueue.main.async {
            observable.value = result
        }
    }
    return observable
}
let requestedZen = Observable(1).flatMap(requestZen)
requestedZen.subscribe { result in
    guard case .Success(let zen) = result  else {return}
    print(zen.text)
}
/*:
 Isn't it a bit tidious to always check for success? Let's define an extension to handle this for us:
 - Note: In Swift 3 we can only put extension constraints to protocols, therefore we're wrapping Result in a ResultType protocol.
 */
protocol ResultType {
    associatedtype Value
    var result: Result<Value> { get }
}

extension Result: ResultType {
    var result: Result<T> { return self }
}

extension Observable where T: ResultType {
    func next(_ f: @escaping (T.Value) -> Void) {
        subscribe { result in
            if case .Success(let value) = result.result {
                f(value)
            }
        }
    }
}

requestedZen.next { zen in print("success: \(zen.text)") } // only gets executed in success case
//: Now there is just a single thing missing: In many cases we only want to continue transforming if the last step was a success (e.g. only parse a json object if the network request was successful). Of course we don't want to unwrap the result in every step, so let's add one last function:
extension Observable where T: ResultType {
    func then<U>(_ transform: @escaping (T.Value) -> Observable<Result<U>>) -> Observable<Result<U>> {
        return flatMap { result in
            switch result.result {
            case let .Success(v): return transform(v)
            case let .Error(error): return Observable<Result<U>>(.Error(error))
            }
        }
    }
}

func uppercasedZen(zen: Zen) -> Observable<Result<Zen>> { // note that the argument here is a `Zen`, not a `Result<Zen>`!
    return Observable(.Success(Zen(text: zen.text.uppercased())))
}
requestedZen.then(uppercasedZen).next { print("uppercased: \($0.text)") }
/*:
 ## Where to go from here
 You've seen the basics of reactive programming, how Observables update their subscribers, how to map and flatMap box types, how to handle future values with observables and even how to handle asynchronous errors with `then` and `next`.
 
 If you're interested in more details you should have at the [Interstellar library](https://github.com/jensravens/interstellar) - you've already seen about half of the source code. Even if you aim for something more feature complete like [RxSwift](https://github.com/ReactiveX/RxSwift/) or [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa/) the basics are the same - just observables and transformations.
*/
// to enable networking inside of a playground
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true