import Foundation
import Metal

typealias Vertex = (Float, Float)

struct LinkMesh {
  let detailLevel: Int
  let radius: Float = 250
  
  private let convexVertices: [Vertex]
  private let triangleVertices: [Vertex]
  private let triangleVertexInputs: [VertexInput]
  
  static func build(detailLevel: Int, radius: Float = 250) -> Self {
    let convexVertices: [Vertex] = (0..<detailLevel).map({ (i: Int) -> Vertex in
      let theta = Float(i) * Float.pi * 2.0 / Float(detailLevel)
      return (
        radius * cos(theta),
        radius * sin(theta)
      )
    })
    
    
    let firstVertex = convexVertices.first!
    let triangleVertices = (1..<convexVertices.count - 1).flatMap({ (i: Int) -> [Vertex] in
      let secondVertex = convexVertices[i]
      let thirdVertex = convexVertices[i + 1]
      return [firstVertex, secondVertex, thirdVertex]
    })
    
    let triangleVertexInputs = triangleVertices.map { x, y in VertexInput(position: SIMD2<Float>(x, y)) }
    
    return LinkMesh(detailLevel: detailLevel, convexVertices: convexVertices, triangleVertices: triangleVertices, triangleVertexInputs: triangleVertexInputs)
  }
  
  var triangleVerticesCount: Int {
    return triangleVertices.count
  }
  
  func toVertexBuffer(forDevice device: MTLDevice) -> MTLBuffer {
    return device.makeBuffer(
      bytes: triangleVertexInputs,
      length:triangleVertexInputs.count * MemoryLayout<SIMD2<Float>>.size,
      options: MTLResourceOptions.cpuCacheModeWriteCombined
    )!
  }
}
