import Foundation
import Metal

protocol TupleEncodable {
  var x: Float { get }
  var y: Float { get }
  var z: Float { get }
}

extension TupleEncodable {
  func toTuple() -> (Float, Float, Float) {
    return (x, y, z)
  }
}

struct Point: TupleEncodable {
  let x: Float
  let y: Float
  let z: Float
}

struct Vector: TupleEncodable {
  let x: Float
  let y: Float
  let z: Float
  
  func length() -> Float {
    return sqrtf(x * x + y * y + z * z)
  }
  
  func normalize() -> Vector {
    return self / length()
  }
}

func /(lhs: Vector, rhs: Float) -> Vector {
  return Vector(
    x: lhs.x / rhs,
    y: lhs.y / rhs,
    z: lhs.z / rhs
  )
}

func -(lhs: Point, rhs: Point) -> Vector {
  return Vector(
    x: lhs.x - rhs.x,
    y: lhs.y - rhs.y,
    z: lhs.z - rhs.z
  )
}

func +(lhs: Point, rhs: Vector) -> Point {
  return Point(
    x: lhs.x + rhs.x,
    y: lhs.y + rhs.y,
    z: lhs.z + rhs.z
  )
}

struct Vertex {
  let position: Point
  let normal: Vector
  
  func toVertexInput() -> VertexInput {
    return VertexInput.from(position: position.toTuple(), normal: normal.toTuple())
  }
  
  func rotatedAboutOrigin() -> Vertex {
    return Vertex(
      position: Point(x: -position.x, y: -position.y, z: position.z),
      normal: Vector(x: -normal.x, y: -normal.y, z: normal.z)
    )
  }
}

protocol TriangleVertexEncodable {
  var triangleVertices: [Vertex] { get }
}

extension TriangleVertexEncodable {
  var triangleVerticesCount: Int {
    return triangleVertices.count
  }
  
  func toTriangleVertexBuffer(forDevice device: MTLDevice) -> MTLBuffer {
    let triangleVertexInputs = triangleVertices.map { $0.toVertexInput() }
    
    return device.makeBuffer(
      bytes: triangleVertexInputs,
      length: triangleVertices.count * MemoryLayout<VertexInput>.size,
      options: MTLResourceOptions.cpuCacheModeWriteCombined
    )!
  }
}

extension TriangleVertexEncodable {
  var lineVerticesCount: Int {
    return triangleVertices.count * 2
  }
  
  func toLineVertexBuffer(forDevice device: MTLDevice) -> MTLBuffer {
    let lineVertices = (0..<triangleVertices.count).flatMap { index -> [Vertex] in
      return [triangleVertices[index], triangleVertices[(index + 1) % triangleVertices.count]]
    }
    
    let lineVertexInputs = lineVertices.map { $0.toVertexInput() }
    
    return device.makeBuffer(
      bytes: lineVertexInputs,
      length: lineVerticesCount * MemoryLayout<VertexInput>.size,
      options: MTLResourceOptions.cpuCacheModeWriteCombined
    )!
  }
}
