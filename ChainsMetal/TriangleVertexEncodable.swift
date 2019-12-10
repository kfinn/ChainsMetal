import Foundation
import Metal

typealias Vertex = (Float, Float)

protocol TriangleVertexEncodable {
  var triangleVertices: [Vertex] { get }
}

extension TriangleVertexEncodable {
  var triangleVerticesCount: Int {
    return triangleVertices.count
  }
  
  func toVertexBuffer(forDevice device: MTLDevice) -> MTLBuffer {
    let triangleVertexInputs = triangleVertices.map { x, y in VertexInput.from(x: x, y: y) }
    
    return device.makeBuffer(
      bytes: triangleVertexInputs,
      length: triangleVertices.count * MemoryLayout<VertexInput>.size,
      options: MTLResourceOptions.cpuCacheModeWriteCombined
    )!
  }
}
