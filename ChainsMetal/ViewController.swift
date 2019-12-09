import UIKit
import MetalKit

class ViewController: UIViewController {
  var metalView: MetalView!
  var metalViewConstraints: [NSLayoutConstraint]? {
    didSet {
      if let constraints = oldValue {
        view.removeConstraints(constraints)
      }
      if let constraints = metalViewConstraints {
        view.addConstraints(constraints)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.white
    
    metalView = MetalView()
    metalView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(metalView)
    
    self.updateViewConstraints()
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    metalViewConstraints = metalView.constraintsToFillSuperview()
  }
}
