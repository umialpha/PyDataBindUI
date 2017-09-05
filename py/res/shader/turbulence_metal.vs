using namespace metal;

#ifndef GPU_SKIN_ENABLE
#define GPU_SKIN_ENABLE FALSE
#endif

#include "shaderlib/skin_metal.vs"


// ATTRIBUTES
struct VertexInput
{
	float4 texcoord2 [[attribute(TEXTURE2)]];
	float4 texcoord1 [[attribute(TEXTURE1)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 diffuse [[attribute(DIFFUSE)]];
	float4 position [[attribute(POSITION)]];

#if GPU_SKIN_ENABLE
    float4 blendWeights [[attribute(BLENDWEIGHT)]];
    uint4 blendIndices [[attribute(BLENDINDICES)]];
#endif
};

// UNIFORM
struct VSConstants
{	
	float4x4 wvp;
	float4x4 texTrans0;

	float time;

	float3 vx_vy_scale1;
	float3 vx_vy_scale2;

#if GPU_SKIN_ENABLE
    float4 BoneVec[MAX_BONES*2];
#endif
};

// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float4 UV0;
	float4 UV1;
	float4 UV2;
	float4 Color;
};

vertex VertexOutput VS_OneTex(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput  vData [ [stage_in] ],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	float4 pos = vData.position;
	float4 nor = float4(0);
#if GPU_SKIN_ENABLE
    SkinOutput skin_out = GetSkin(vData.blendWeights, vData.blendIndices, vData.position, nor, constants.BoneVec);
    pos = float4(skin_out.pos, 1);
    nor = float4(skin_out.nor, 0);
#endif
	output.position = (constants.wvp * pos);
	output.Color = vData.diffuse;
	float4 texc = float4(vData.texcoord0.xy, 1, 0);
	output.UV0 = constants.texTrans0 * texc;
	output.UV1.xy = vData.texcoord0.xy * constants.vx_vy_scale1.z + constants.vx_vy_scale1.xy * constants.time;
	output.UV2.xy = vData.texcoord0.xy * constants.vx_vy_scale2.z + constants.vx_vy_scale2.xy * constants.time;

#endif
	return output;
}