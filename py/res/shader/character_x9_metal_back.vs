#include <metal_graphics>
#include <metal_geometric>
#include <metal_matrix>
#include <metal_texture>
#include "shaderlib/skin_metal.vs"
using namespace metal;

#ifndef NEOX_METAL_NO_ATTR
struct VertexInput
{
	float4 position [ [attribute(POSITION)] ];
	float4 texcoord0 [ [attribute(TEXTURE0)] ];
	float4 diffuse [ [attribute(COLOR0)] ];
#ifdef NEED_NORMAL
	float4 normal [ [attribute(NORMAL)] ];
	float4 binormal [ [attribute(BINORMAL)] ];
	float4 tangent [ [attribute(TANGENT)] ];
#endif

#if GPU_SKIN_ENABLE
	float4 blendWeights [ [attribute(BLENDWEIGHT)] ];
	float4 blendIndices [ [attribute(BLENDINDICES)] ];
#endif
};
#endif

struct VSConstants
{
	float4x4 world;
	float4x4 view;
	float4x4 viewProjection;
	float4x4 wv;

	float4x4 wvp;
	float4x4 texTrans0;

	float3 model_offset;

#if LIGHT_MAP_ENABLE
	float4x4 lightmapTrans;
#endif
	// uniform lowp int flipUV;
#if SHADOW_MAP_ENABLE
	float4x4 lightViewProj;
#endif

#if GPU_SKIN_ENABLE
	float4 BoneVec[MAX_BONES*2];
#endif
};

struct VertexOutput
{
	float4 position [ [position] ];
	float4 UV0;
	//varying lowp vec4 Color;
#ifdef NEED_POS_WORLD
	float4 PosWorld;
#endif

#ifdef NEED_NORMAL_WORLD
	float3 NormalWorld;
	float3 TangentWorld;
	float3 BinormalWorld;
#endif

#if SHADOW_MAP_ENABLE
	float4 PosLightProj;
#endif

#if FOG_ENABLE
	float4 FogResult;
#endif
};

vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
				VertexInput  vData [ [stage_in] ],
#endif
				constant VSConstants &constants[ [buffer(0)] ])
{
	VertexOutput output;
	vec4 pos = position;
	vec4 nor = vec4(0);
	vec4 bino = vec4(0);
	vec4 tang = vec4(0);
	
#ifdef NEED_NORMAL
	nor = normal;
#endif

#ifdef NEED_NORMAL
	nor = normal;
#endif
	
	GetSkin()

#ifndef NEOX_METAL_NO_ATTR
	output.position = (constants.wvp * vData.position);
	float4 texc = float4(vData.texcoord0.xy, 1, 0);
	output.UV0 = constants.texTrans0 * texc;
#endif
	return output;
}


