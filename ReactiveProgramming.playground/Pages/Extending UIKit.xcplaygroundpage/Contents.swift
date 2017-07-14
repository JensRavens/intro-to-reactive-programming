/*:
 ## Extending UIKit
 Reactive programming? That's already all of it. Something changes, you react to it. Let's see where this might be useful by extending UIKit to use our observable:
 */
import UIKit
private var TextSignalHandle: UInt8 = 0
extension UITextField {
    var observableText: Observable<String> {
        if let observable = objc_getAssociatedObject(self, &TextSignalHandle) as? Observable<String> {
            return observable
        } else {
            let observable = Observable(self.text ?? "")
            objc_setAssociatedObject(self, &TextSignalHandle, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            addTarget(self, action: #selector(handleUpdate), for: UIControlEvents.editingChanged)
            return observable
        }
    }
    
    @objc private func handleUpdate() {
        observableText.value = self.text ?? ""
    }
}
/*:
 Using the Objective C runtime we can define a property on `UITextField`, even though we didn't implement the class ourself. Ever heard you can't define stored properties on already defined classes? Yes, you can.
 \
 This code checks if there is already an `Observable<String>` defined and if not, creates a new one with the current text of the text field. Therefore there is a single observable per textfield, bound to the lifecycle of the text field - when the textfield deallocates, it will also let go of the observable.
 */
import PlaygroundSupport
class MyViewController: TextViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = self.label
        textField.observableText.subscribe { (text) in label.text = text }
        print(self.view.subviews.first!)
    }
}
PlaygroundPage.current.liveView = UINavigationController(rootViewController: MyViewController())
/*: 
 Just by adding a simple subscribe call now your label will stay in sync with the text field.
 \
 But there's more. You can use observables to replace notifications (`Observable<KeyboardInset>`), target-actions (as seen here for text fields), delegation (`Observable<CLLocation>` on `CLLocationManager`) and KVO. All in a typesafe and easy to user manner.
 \
 [Next: Map your way to glory](@next)
*/
