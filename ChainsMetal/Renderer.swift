import MetalKit
import simd

struct VertexUniforms {
  var viewportSize: SIMD2<UInt32>
  var lightDirection: SIMD3<Float>
  var albedo: SIMD3<Float>
  var diffuseLightColor: SIMD3<Float>
  var specularLightColor: SIMD3<Float>
}

struct VertexInput {
  var position: SIMD3<Float>
  var normal: SIMD3<Float>
  
  static func from(position: (Float, Float, Float), normal: (Float, Float, Float)) -> Self {
    return Self(
      position: SIMD3<Float>(position.0, position.1, position.2),
      normal: SIMD3<Float>(normal.0, normal.1, normal.2)
    )
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
    return VertexUniforms(
      viewportSize: SIMD2<UInt32>(
        UInt32(view.drawableSize.width),
        UInt32(view.drawableSize.height)
      ),
      lightDirection: SIMD3<Float>(0, 1, 0),
      albedo: SIMD3<Float>(0.5, 0.5, 0.5),
      diffuseLightColor: SIMD3<Float>(1, 0, 0),
      specularLightColor: SIMD3<Float>(1, 1, 1)
    )
  }()
  
  lazy var mesh: TriangleVertexEncodable = {
    return TorusMesh.build(detailLevel: 17)
  }()
  
  lazy var meshVertexBuffer: MTLBuffer = {
    return mesh.toVertexBuffer(forDevice: device)
  }()
  
  init(view: MTKView) {
    self.view = view
    super.init()
  }
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    vertexUniforms = VertexUniforms(
      viewportSize: SIMD2<UInt32>(UInt32(size.width), UInt32(size.height)),
      lightDirection: SIMD3<Float>(0, 1, 0),
      albedo: SIMD3<Float>(0.5, 0.5, 0.5),
      diffuseLightColor: SIMD3<Float>(1, 0, 0),
      specularLightColor: SIMD3<Float>(1, 1, 1)
    )
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
          znear: -1000,
          zfar: 1000
        )
      )
      
      renderEncoder.setRenderPipelineState(renderPipelineState)
      
      renderEncoder.setVertexBuffer(meshVertexBuffer, offset: 0, index: 0)
                  
      renderEncoder.setVertexBytes(
        &vertexUniforms,
        length: MemoryLayout<VertexUniforms>.size,
        index: 1
      )
      
      renderEncoder.setFragmentBytes(
        &vertexUniforms,
        length: MemoryLayout<VertexUniforms>.size,
        index: 0
      )
      
      renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: mesh.triangleVerticesCount)
      renderEncoder.endEncoding()
      
      commandBuffer.present(currentDrawable)
      commandBuffer.commit()
    }
  }
}
