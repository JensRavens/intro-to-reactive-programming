/*:
 ## A slightly more sophisticated use case
 Transforming a string might be nice, but that's quite far from the usual use cases of every day development. Let's download some json and parse it.
 */
import Foundation

let api = URL(string: "https://api.github.com/zen")!

/// Zen encodes a wisdom, downloaded from the internet.
struct Zen {
    let text: String
}

/// This will download a zen from a url on another thread and return to the main thread.
func downloadZen(id: Int) -> Observable<Data?> {
    let observable = Observable<Data?>(nil)
    DispatchQueue.global().async {
        let zen = NSData(contentsOf: api)
        DispatchQueue.main.async {
            observable.value = zen as Data?
        }
    }
    return observable
}

/// This parses downloaded zen data into a string.
func parseData(data: Data?) -> String? {
    return data.flatMap { data in String(data: data, encoding: .utf8) }
}

/// Get a zen out of a downloaded string
func parseZen(string: String?) -> Zen? {
    return string.map { string in Zen(text: string) }
}

let zenID = Observable(1)
let downloadedZen: Observable<Zen?> = zenID.flatMap(downloadZen).map(parseData).map(parseZen)
downloadedZen.subscribe { zen in
    if let zen = zen {
        print(zen.text)
    } else {
        print("downloading data");
    }
}
// will print: "downloading data", then a zen from github
//: To download another zen, we just have to update the id:
zenID.value = 2
// will print: "downloading data", then another zen from github

//: [Next: Asynchornous error handling](@next)

// to enable networking inside of a playground
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true