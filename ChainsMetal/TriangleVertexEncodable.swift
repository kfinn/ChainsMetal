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

struct Vertex {
  let position: Point
  let normal: Vector
  
  func toVertexInput() -> VertexInput {
    return VertexInput.from(position: position.toTuple(), normal: normal.toTuple())
  }
}

protocol TriangleVertexEncodable {
  var triangleVertices: [Vertex] { get }
}

extension TriangleVertexEncodable {
  var triangleVerticesCount: Int {
    return triangleVertices.count
  }
  
  func toVertexBuffer(forDevice device: MTLDevice) -> MTLBuffer {
    let triangleVertexInputs = triangleVertices.map { $0.toVertexInput() }
    
    return device.makeBuffer(
      bytes: triangleVertexInputs,
      length: triangleVertices.count * MemoryLayout<VertexInput>.size,
      options: MTLResourceOptions.cpuCacheModeWriteCombined
    )!
  }
}
