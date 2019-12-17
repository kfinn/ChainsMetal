import UIKit
import MetalKit

class MetalView: UIView {
  let mtlDevice = MTLCreateSystemDefaultDevice()!

  lazy var mtkView: MTKView = {
    let mtlView = MTKView()
    mtlView.translatesAutoresizingMaskIntoConstraints = false
    mtlView.device = mtlDevice
    mtlView.enableSetNeedsDisplay = true

    return mtlView
  }()
  
  var mtkViewConstraints: [NSLayoutConstraint]? {
    didSet {
      if let constraints = oldValue {
        removeConstraints(constraints)
      }
      if let constraints = mtkViewConstraints {
        addConstraints(constraints)
      }
    }
  }
  
  lazy var renderer: Renderer = {
    return Renderer(view: mtkView)
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  func commonInit() {
    mtkView.delegate = renderer
    addSubview(mtkView)
    renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    setNeedsUpdateConstraints()
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    mtkViewConstraints = mtkView.constraintsToFillSuperview()
  }
}
