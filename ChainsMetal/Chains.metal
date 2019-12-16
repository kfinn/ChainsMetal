#include <metal_stdlib>
using namespace metal;

typedef struct {
  uint2 viewportSize;
  float3 lightDirection;
  float3 albedo;
  float3 diffuseLightColor;
  float3 specularLightColor;
} VertexUniforms;

typedef struct {
  float3 position;
  float3 normal;
}  VertexInput;

typedef struct {
  float4 position [[position]];
  float3 normal;
  float nDotL;
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
  
  out.nDotL = dot(out.normal, uniforms.lightDirection);
  
  return out;
}

fragment float4 fragmentShader(
                               VertexOutput in [[stage_in]],
                               constant VertexUniforms &uniforms [[buffer(0)]]
                               ) {
  
  float3 albedo = uniforms.albedo;
  
  float3 diffuse = in.nDotL * uniforms.diffuseLightColor;

  float3 cameraDirection = float3(0, 0, 1);
  float3 cameraReflection = cameraDirection - 2 * dot(cameraDirection, in.normal) * in.normal;
  float3 negativeCameraReflection = -1 * cameraReflection;
  float cameraReflectionDotLightDirection = dot(negativeCameraReflection, uniforms.lightDirection);

  float3 specular = uniforms.specularLightColor * cameraReflectionDotLightDirection;
  
  float4 out;
  out.rgb = albedo + diffuse + specular;
  out.a = 1;
  return out;
}
