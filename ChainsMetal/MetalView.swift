import UIKit
import MetalKit

struct Pan {
  let startingLightDirection: Vector
}

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
  
  lazy var panGestureRecognizer: UIGestureRecognizer = {
    let panGestureRecognizer = UIPanGestureRecognizer()
    panGestureRecognizer.addTarget(self, action: #selector(handlePan))
    return panGestureRecognizer
  }()
  
  var currentPan: Pan?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  func commonInit() {
    addGestureRecognizer(panGestureRecognizer)
    
    mtkView.delegate = renderer
    addSubview(mtkView)
    renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    setNeedsUpdateConstraints()
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    mtkViewConstraints = mtkView.constraintsToFillSuperview()
  }
  
  @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
    if let currentPan = currentPan {
      if gestureRecognizer.state == .cancelled {
        renderer.lightDirection = currentPan.startingLightDirection
        return
      }
      
      let translationCGPoint = gestureRecognizer.translation(in: self)
      let translation = Point(x: Float(translationCGPoint.x), y: Float(translationCGPoint.y), z: 0)

      renderer.lightDirection =
        currentPan.startingLightDirection
        .rotatedAboutX(radians: translation.y / 100)
        .rotatedAboutY(radians: translation.x / 100)
      
      if gestureRecognizer.state == .ended {
        self.currentPan = nil
      }
    } else if gestureRecognizer.state == .began {
      currentPan = Pan(
        startingLightDirection: renderer.lightDirection
      )
    }
  }
}
