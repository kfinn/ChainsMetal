import Foundation
import Metal

struct CircleMesh: TriangleVertexEncodable {
  let detailLevel: Int
  let radius: Float = 250
  
  let triangleVertices: [Vertex]
  
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
    
    return CircleMesh(detailLevel: detailLevel, triangleVertices: triangleVertices)
  }
}
