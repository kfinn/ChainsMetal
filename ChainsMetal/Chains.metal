#include <metal_stdlib>
using namespace metal;

typedef struct {
  uint2 viewportSize;
} VertexUniforms;

typedef struct {
  float2 position;
}  VertexInput;

typedef struct {
  float4 position [[position]];
} VertexOutput;

vertex VertexOutput vertexShader(
                                 uint vertexID [[vertex_id]],
                                 constant VertexInput *vertices [[buffer(0)]],
                                 constant VertexUniforms &uniforms [[buffer(1)]]
                                 ) {
  VertexOutput out;
  
  float2 pixelSpacePosition = vertices[vertexID].position.xy;
  float2 viewportSize = float2(uniforms.viewportSize);
  
  out.position = float4(0, 0, 0.5, 1);
  out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
  return out;
}

fragment float4 fragmentShader(VertexOutput in [[stage_in]]) {
  float4 out = float4(1, 1, 1, 1);
  return out;
}
