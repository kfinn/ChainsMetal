import Foundation
import Metal

struct TorusMesh: TriangleVertexEncodable {
  let triangleVertices: [Vertex]
  
  static func build(detailLevel: Int, radius: Float = 250) -> Self {
    let tubeRadius = radius / 3.0
    let stride = Float.pi * 2.0 / Float(detailLevel)
        
    let cornerRings: [[Vertex]] = (0..<detailLevel).map({ cornerIndex in
      let cornerAngle = Float(cornerIndex) * stride
      let cornerPosition = Point(
        x: radius * cos(cornerAngle),
        y: radius * sin(cornerAngle),
        z: 0
      )

      return (0..<detailLevel).map({ vertexIndex -> Vertex in
        let vertexAngle = Float(vertexIndex) * stride
        let vertexPosition = Point(
          x: cornerPosition.x + tubeRadius * cos(vertexAngle) * cos(cornerAngle),
          y: cornerPosition.y + tubeRadius * cos(vertexAngle) * sin(cornerAngle),
          z: cornerPosition.z + tubeRadius * sin(vertexAngle)
        )
        let vertexNormal = (vertexPosition - cornerPosition).normalize()
        
        return Vertex(
          position: vertexPosition,
          normal: vertexNormal
        )
      })
    })
    
    let triangleVertices = (0..<cornerRings.count).flatMap({ ringIndex -> [Vertex] in
      let currentRing = cornerRings[ringIndex]
      let nextRing = cornerRings[(ringIndex + 1) % cornerRings.count]
      
      return (0..<currentRing.count).flatMap({ vertexIndex -> [Vertex] in
        let currentRingCurrentVertex = currentRing[vertexIndex]
        let currentRingNextVertex = currentRing[(vertexIndex + 1) % currentRing.count]
        let nextRingCurrentVertex = nextRing[vertexIndex % nextRing.count]
        let nextRingNextVertex = nextRing[(vertexIndex + 1) % nextRing.count]
        
        return [
          currentRingCurrentVertex,
          nextRingCurrentVertex,
          currentRingNextVertex,
          
          nextRingCurrentVertex,
          currentRingNextVertex,
          nextRingNextVertex
        ]
      })
    })
    
    return Self(triangleVertices: triangleVertices)
  }
}
