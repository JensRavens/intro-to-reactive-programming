import UIKit

open class TextViewController: UIViewController {
    public var label: UILabel = { return UILabel(frame: CGRect(x: 0, y: 88, width: 320, height: 44)) }()
    public var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 44, width: 320, height: 44))
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        title = "Example View Controller"
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(label)
    }
}

