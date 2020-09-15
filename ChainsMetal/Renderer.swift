import MetalKit
import simd

extension VertexInput {
  static func from(position: (Float, Float, Float), normal: (Float, Float, Float)) -> Self {
    return Self(
      position: SIMD3<Float>(position.0, position.1, position.2),
      normal: SIMD3<Float>(normal.0, normal.1, normal.2)
    )
  }
}

class Renderer: NSObject, MTKViewDelegate {
  let view: MTKView
  
  var lightDirection: Vector = Vector(x: -1, y: 1, z: 0).normalize() {
    didSet {
      view.setNeedsDisplay()
    }
  }

  var device: MTLDevice {
    return view.device!
  }

  lazy var commandQueue: MTLCommandQueue = {
    return device.makeCommandQueue()!
  }()
  
  lazy var library: MTLLibrary = {
    return device.makeDefaultLibrary()!
  }()
  
  lazy var vertexFunction: MTLFunction = {
    return library.makeFunction(name: "vertexShader")!
  }()
  
  lazy var fragmentFunction: MTLFunction = {
    return library.makeFunction(name: "fragmentShader")!
  }()
  
  lazy var renderPipelineDescriptor: MTLRenderPipelineDescriptor = {
    let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
    renderPipelineDescriptor.label = "Chains#pipeline"
    renderPipelineDescriptor.vertexFunction = vertexFunction
    renderPipelineDescriptor.fragmentFunction = fragmentFunction
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
    renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    
    return renderPipelineDescriptor
  }()
  
  lazy var renderPipelineState: MTLRenderPipelineState = {
    return try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
  }()
  
  lazy var depthStencilDescriptor: MTLDepthStencilDescriptor = {
    let depthStencilDescriptor = MTLDepthStencilDescriptor()
    depthStencilDescriptor.depthCompareFunction = .less
    depthStencilDescriptor.isDepthWriteEnabled = true
    
    return depthStencilDescriptor
  }()
  
  lazy var depthStencilState: MTLDepthStencilState = {
    return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
  }()
  
  lazy var viewportSize: CGSize = {
    return view.drawableSize
  }()
  
  var vertexUniforms: VertexUniforms {
    return VertexUniforms(
      viewportSize: SIMD2<UInt32>(
        UInt32(view.drawableSize.width),
        UInt32(view.drawableSize.height)
      ),
      lightDirection: SIMD3<Float>(lightDirection.x, lightDirection.y, lightDirection.z),
      albedo: SIMD3<Float>(1, 0, 0),
      diffuseLightColor: SIMD3<Float>(1, 1, 1),
      specularLightColor: SIMD3<Float>(1, 1, 1)
    )
  }
  
  lazy var mesh: TriangleVertexEncodable = {
    return ChainLinkMesh.build(detailLevel: 7)
  }()
  
  lazy var instances: [LinkInstanceInput] = {
    return (0...4).map { index -> LinkInstanceInput in
      let translationTransform = matrix_float4x4.translation(x: 0, y: 1000 - Float(index) * 750, z: 0)
      let rotationTransform = matrix_float4x4.rotation(
        axis: SIMD3<Float>(0, 1, 0),
        angle: Float(index) * Float.pi / 2
      )
      
      let modelTransform = translationTransform * rotationTransform
      let normalTransform = modelTransform.upperLeft3x3()
      
      return LinkInstanceInput(
        modelTransform: modelTransform,
        normalTransform: normalTransform
      )
    }
  }()
  
  init(view: MTKView) {
    self.view = view
    super.init()
  }
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    viewportSize = size
  }
  
  func draw(in view: MTKView) {
    if
      let renderPassDescriptor = view.currentRenderPassDescriptor,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
      let currentDrawable = view.currentDrawable
    {
      var currentViewportUniforms = vertexUniforms
      var currentInstances = instances

      commandBuffer.label = "Chains#draw"
      
      renderEncoder.setViewport(
        MTLViewport(
          originX: 0,
          originY: 0,
          width: Double(vertexUniforms.viewportSize.x),
          height: Double(vertexUniforms.viewportSize.y),
          znear: -1000,
          zfar: 1000
        )
      )
      
      renderEncoder.setRenderPipelineState(renderPipelineState)
      renderEncoder.setDepthStencilState(depthStencilState)
      renderEncoder.setCullMode(.back)
      
      renderEncoder.setVertexBytes(
        &currentViewportUniforms,
        length: MemoryLayout<VertexUniforms>.size,
        index: Int(VertexInputIndexVertexUniforms.rawValue)
      )
      
      renderEncoder.setVertexBuffer(
        mesh.toTriangleVertexBuffer(forDevice: device),
        offset: 0,
        index: Int(VertexInputIndexVertexInput.rawValue)
      )

      renderEncoder.setVertexBytes(
        &currentInstances,
        length: MemoryLayout<LinkInstanceInput>.size * currentInstances.count,
        index: Int(VertexInputIndexLinkInstanceInput.rawValue)
      )
      
      renderEncoder.setFragmentBytes(
        &currentViewportUniforms,
        length: MemoryLayout<VertexUniforms>.size,
        index: Int(FragmentInputIndexVertexUniforms.rawValue)
      )
      
      renderEncoder.drawPrimitives(
        type: .triangle,
        vertexStart: 0,
        vertexCount: mesh.triangleVerticesCount,
        instanceCount: currentInstances.count
      )
      renderEncoder.endEncoding()
      
      commandBuffer.present(currentDrawable)
      commandBuffer.commit()
    }
  }
}
