using namespace metal;

#include "shaderlib/skin_metal.vs"

#ifndef NEOX_METAL_NO_ATTR
//ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];
	float4 normal [[attribute(NORMAL)]];
#if GPU_SKIN_ENABLE
	float4 blendWeights [[attribute(BLENDWEIGHT)]];
	uint4 blendIndices [[attribute(BLENDINDICES)]];
#endif
};
#endif

// UNIFORM
struct VSConstants
{
	float4x4 wvp;
	float4x4 wv;
#if GPU_SKIN_ENABLE
	float4 BoneVec[360];
#endif
};

// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float3 normal_view;
};


vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	float4 pos = vData.position;
	float4 nor = vData.normal;

#if GPU_SKIN_ENABLE
	SkinOutput skin_out = GetSkin(vData.blendWeights, vData.blendIndices, vData.position, nor, constants.BoneVec);
	pos = float4(skin_out.pos, 1);
	nor = float4(skin_out.nor, 0);
#endif

	output.position = constants.wvp * pos;

	float3x3 normal_mat = float3x3(float3(constants.wv[0]), float3(constants.wv[1]), float3(constants.wv[2]));
	output.normal_view = normalize(normal_mat * nor.xyz);
#endif
	return output;
}
