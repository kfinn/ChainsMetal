import simd

extension matrix_float4x4 {
  static func translation(x: Float, y: Float, z: Float) -> Self {
    return matrix_float4x4(
      SIMD4<Float>(1, 0, 0, 0),
      SIMD4<Float>(0, 1, 0, 0),
      SIMD4<Float>(0, 0, 1, 0),
      SIMD4<Float>(x, y, z, 1)
    )
  }
  
  static func rotation(axis: SIMD3<Float>, angle: Float) -> Self {
    let c = cos(angle);
    let s = sin(angle);
    
    let x = SIMD4<Float>(
        axis.x * axis.x + (1 - axis.x * axis.x) * c,
        axis.x * axis.y * (1 - c) - axis.z*s,
        axis.x * axis.z * (1 - c) + axis.y * s,
        0
      )
    
    let y = SIMD4<Float>(
        axis.x * axis.y * (1 - c) + axis.z * s,
        axis.y * axis.y + (1 - axis.y * axis.y) * c,
        axis.y * axis.z * (1 - c) - axis.x * s,
        0
      )
    
    let z = SIMD4<Float>(
        axis.x * axis.z * (1 - c) - axis.y * s,
        axis.y * axis.z * (1 - c) + axis.x * s,
        axis.z * axis.z + (1 - axis.z * axis.z) * c,
        0
      )
    
    let w = SIMD4<Float>(0, 0, 0, 1)

    return matrix_float4x4(x, y, z, w)
  }
  
  func upperLeft3x3() -> matrix_float3x3 {
    return matrix_float3x3(
      SIMD3<Float>(self[0][0], self[0][1], self[0][2]),
      SIMD3<Float>(self[1][0], self[1][1], self[1][2]),
      SIMD3<Float>(self[2][0], self[2][1], self[2][2])
    )
  }
}
