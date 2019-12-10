import MetalKit
import simd

struct VertexUniforms {
  var viewportSize: SIMD2<UInt32>
}

struct VertexInput {
  var position: SIMD3<Float>
  
  static func from(x: Float, y: Float) -> Self {
    return from(x: x, y: y, z: 0)
  }
  
  static func from(x: Float, y: Float, z: Float) -> Self {
    return Self(position: SIMD3<Float>(x, y, z))
  }
}

class Renderer: NSObject, MTKViewDelegate {
  let view: MTKView

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
    
    return renderPipelineDescriptor
  }()
  
  lazy var renderPipelineState: MTLRenderPipelineState = {
    return try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
  }()
  
  lazy var vertexUniforms: VertexUniforms = {
    return VertexUniforms(viewportSize: SIMD2<UInt32>(UInt32(view.drawableSize.width), UInt32(view.drawableSize.height)))
  }()
  
  lazy var linkMesh: TriangleVertexEncodable = {
    return AnnulusMesh.build(detailLevel: 7)
  }()
  
  lazy var linkVertexBuffer: MTLBuffer = {
    return linkMesh.toVertexBuffer(forDevice: device)
  }()
  
  init(view: MTKView) {
    self.view = view
    super.init()
  }
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    vertexUniforms = VertexUniforms(viewportSize: SIMD2<UInt32>(UInt32(size.width), UInt32(size.height)))
  }
  
  func draw(in view: MTKView) {
    if
      let renderPassDescriptor = view.currentRenderPassDescriptor,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
      let currentDrawable = view.currentDrawable
    {
      commandBuffer.label = "Chains#draw"
      
      renderEncoder.setViewport(
        MTLViewport(
          originX: 0,
          originY: 0,
          width: Double(vertexUniforms.viewportSize.x),
          height: Double(vertexUniforms.viewportSize.y),
          znear: -1,
          zfar: 1
        )
      )
      
      renderEncoder.setRenderPipelineState(renderPipelineState)
      
      renderEncoder.setVertexBuffer(linkVertexBuffer, offset: 0, index: 0)
                  
      renderEncoder.setVertexBytes(
        &vertexUniforms,
        length: MemoryLayout<VertexUniforms>.size,
        index: 1
      )
      
      renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: linkMesh.triangleVerticesCount)
      renderEncoder.endEncoding()
      
      commandBuffer.present(currentDrawable)
      commandBuffer.commit()
    }
  }
}
