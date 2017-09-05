using namespace metal;
#include "shaderlib/skin_metal.vs"


// ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];

#if GPU_SKIN_ENABLE
    float4 blendWeights [[attribute(BLENDWEIGHT)]];
    uint4 blendIndices [[attribute(BLENDINDICES)]];
#endif
};

// UNIFORM
struct VSConstants
{
	float4x4 wvp;
	float4x4 SprTrans;

#if GPU_SKIN_ENABLE
    float4 BoneVec[MAX_BONES*2];
#endif
};

// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float2 uv;
};

vertex VertexOutput main_VS(
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
 	output.position =  constants.wvp * pos;	
	float4 texc = float4(vData.texcoord0.xy, 1.0, 0.0);
	output.uv = (constants.SprTrans * texc).xy;

#endif

	return output;
}