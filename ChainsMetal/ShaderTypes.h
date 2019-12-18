#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

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

#endif /* ShaderTypes_h */
