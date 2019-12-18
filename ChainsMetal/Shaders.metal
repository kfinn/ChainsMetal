#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

typedef struct {
  float4 position [[position]];
  float3 normal;
  float nDotL;
} VertexOutput;

vertex VertexOutput vertexShader(
                                 uint vertexID [[vertex_id]],
                                 uint instanceID [[instance_id]],
                                 constant VertexUniforms &uniforms [[buffer(VertexInputIndexVertexUniforms)]],
                                 constant VertexInput *vertices [[buffer(VertexInputIndexVertexInput)]],
                                 constant LinkInstanceInput *instances [[buffer(VertexInputIndexLinkInstanceInput)]]
                                 ) {
  VertexOutput out;
  
  LinkInstanceInput instance = instances[instanceID];
  float3 pixelSpacePosition = vertices[vertexID].position;
  float2 viewportSize = float2(uniforms.viewportSize);
  
  float4 position = float4(0, 0, 0, 1);
  position.xyz = pixelSpacePosition;
  position = instance.modelTransform * position;
  position.xy = position.xy / (viewportSize / 2.0);
  position.z = position.z / 1000.0;
  out.position = position;
  
  out.normal = instance.normalTransform * vertices[vertexID].normal;
  
  out.nDotL = dot(out.normal, normalize(uniforms.lightDirection));
  
  return out;
}

fragment float4 fragmentShader(
                               VertexOutput in [[stage_in]],
                               constant VertexUniforms &uniforms [[buffer(0)]]
                               ) {
  
  float3 albedo = uniforms.albedo;
  
  float3 diffuse = (in.nDotL * 0.5 + 0.5) * uniforms.diffuseLightColor;
  float3 global = float3(0.1, 0.1, 0.1);

  float3 cameraDirection = float3(0, 0, 1);
  float3 cameraReflection = cameraDirection - 2 * dot(cameraDirection, in.normal) * in.normal;
  float3 negativeCameraReflection = -1 * cameraReflection;
  float cameraReflectionDotLightDirection = dot(negativeCameraReflection, normalize(uniforms.lightDirection));

  float3 specular = uniforms.specularLightColor * (cameraReflectionDotLightDirection * 0.5 + 0.5);
  
  float4 out;
  out.rgb = albedo * (global + diffuse) + specular;
  out.a = 1;
  return out;
}
