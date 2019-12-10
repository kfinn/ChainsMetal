#include <metal_stdlib>
using namespace metal;

typedef struct {
  uint2 viewportSize;
} VertexUniforms;

typedef struct {
  float3 position;
  float3 normal;
}  VertexInput;

typedef struct {
  float4 position [[position]];
  float3 normal;
} VertexOutput;

vertex VertexOutput vertexShader(
                                 uint vertexID [[vertex_id]],
                                 constant VertexInput *vertices [[buffer(0)]],
                                 constant VertexUniforms &uniforms [[buffer(1)]]
                                 ) {
  VertexOutput out;
  
  float3 pixelSpacePosition = vertices[vertexID].position;
  float2 viewportSize = float2(uniforms.viewportSize);
  
  out.position = float4(0, 0, 0.5, 1);
  out.position.xy = pixelSpacePosition.xy / (viewportSize / 2.0);
  out.position.z = pixelSpacePosition.z / 1000.0;
  
  out.normal = vertices[vertexID].normal;
  return out;
}

fragment float4 fragmentShader(VertexOutput in [[stage_in]]) {
  float3 camera = float3(0, 0, 1);
  float ndotl = dot(camera, in.normal);
  return float4(ndotl, ndotl, ndotl, 1);
}
