import Foundation
import Metal

struct AnnulusMesh: TriangleVertexEncodable {
  let triangleVertices: [Vertex]
  
  static func buildVertex(vertexIndex: Int, detailLevel: Int, radius: Float) -> Vertex {
    let angle = Float(vertexIndex) * Float.pi * 2.0 / Float(detailLevel)
    return (
      radius * cos(angle),
      radius * sin(angle)
    )
  }
  
  static func build(detailLevel: Int, radius: Float = 250, innerRadius: Float = 84) -> Self {
    let outerVertices: [Vertex] = (0..<detailLevel).map({ buildVertex(vertexIndex: $0, detailLevel: detailLevel, radius: radius) })
    let innerVertices: [Vertex] = (0..<detailLevel).map({ buildVertex(vertexIndex: $0, detailLevel: detailLevel, radius: innerRadius )})
        
    let triangleVertices: [Vertex] = (1...outerVertices.count).flatMap({ (i: Int) -> [Vertex] in
      let outerVertex = outerVertices[i % outerVertices.count]
      let innerVertex = innerVertices[i % innerVertices.count]
      let nextOuterVertex = outerVertices[(i + 1) % outerVertices.count]
      let nextInnerVertex = innerVertices[(i + 1) % innerVertices.count]
      
      return [
        outerVertex,
        nextOuterVertex,
        innerVertex,

        innerVertex,
        nextOuterVertex,
        nextInnerVertex
      ]
    })
    
    return AnnulusMesh(triangleVertices: triangleVertices)
  }
}
