#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum VertexInputIndex
{
  VertexInputIndexVertexUniforms = 0,
  VertexInputIndexVertexInput = 1,
  VertexInputIndexLinkInstanceInput = 2,
} VertexInputIndex;

typedef struct {
  simd_uint2 viewportSize;
  simd_float3 lightDirection;
  simd_float3 albedo;
  simd_float3 diffuseLightColor;
  simd_float3 specularLightColor;
} VertexUniforms;

typedef struct {
  simd_float3 position;
  simd_float3 normal;
}  VertexInput;

typedef struct {
  simd_float4x4 modelTransform;
  simd_float3x3 normalTransform;
} LinkInstanceInput;

typedef enum FragmentInputIndex {
  FragmentInputIndexVertexUniforms = 0
} FragmentInputIndex;

#endif /* ShaderTypes_h */
