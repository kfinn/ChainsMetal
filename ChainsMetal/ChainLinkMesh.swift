import Foundation
import Metal

struct ChainLinkMesh: TriangleVertexEncodable {
  let triangleVertices: [Vertex]
  
  static func build(detailLevel: Int, radius: Float = 250) -> Self {
    let tubeRadius = radius / 2.0
    let stride = Float.pi / Float(detailLevel)
    
    let endRings: [[Vertex]] = (0...detailLevel).map({ cornerIndex in
      let cornerAngle = Float(cornerIndex) * stride
      let cornerPosition = Point(
        x: radius * cos(cornerAngle),
        y: radius * sin(cornerAngle),
        z: 0
      )

      return (0..<(detailLevel * 2)).map({ vertexIndex -> Vertex in
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
    
    let bottomRingsOffset = Vector(x: 0, y: radius, z: 0)
    let bottomRings = endRings.map { ring -> [Vertex] in
      return ring.map { vertex -> Vertex in
        return Vertex(position: vertex.position + bottomRingsOffset, normal: vertex.normal)
      }
    }
    
    let topRings = bottomRings.map { bottomRing -> [Vertex] in
      return bottomRing.map { bottomVertex -> Vertex in
        return bottomVertex.rotatedAboutOrigin()
      }
    }
    
    let allRings = bottomRings + topRings
    
    let triangleVertices = (0..<allRings.count).flatMap({ ringIndex -> [Vertex] in
      let currentRing = allRings[ringIndex]
      let nextRing = allRings[(ringIndex + 1) % allRings.count]
      
      return (0..<currentRing.count).flatMap({ vertexIndex -> [Vertex] in
        let currentRingCurrentVertex = currentRing[vertexIndex]
        let currentRingNextVertex = currentRing[(vertexIndex + 1) % currentRing.count]
        let nextRingCurrentVertex = nextRing[vertexIndex % nextRing.count]
        let nextRingNextVertex = nextRing[(vertexIndex + 1) % nextRing.count]
        
        return [
          currentRingCurrentVertex,
          currentRingNextVertex,
          nextRingCurrentVertex,

          currentRingNextVertex,
          nextRingNextVertex,
          nextRingCurrentVertex,
        ]
      })
    })
    
    return Self(triangleVertices: triangleVertices)
  }
}
