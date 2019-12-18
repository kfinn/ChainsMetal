//
//  ShaderTypes.h
//  ChainsMetal
//
//  Created by Kevin Finn on 12/17/19.
//  Copyright © 2019 heptarex. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#include <metal_stdlib>
#else
#import <Foundation/Foundation.h>
#endif

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
