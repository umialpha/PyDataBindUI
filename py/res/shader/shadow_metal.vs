using namespace metal;
#include "shaderlib/skin_metal.vs"

#ifndef NEOX_METAL_NO_ATTR
//ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];
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
    float4x4 world;
	float4x4 view;
};

// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float4 vPosition;
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

	output.position = (constants.wvp * pos);

	output.vPosition = (constants.view * constants.world * pos);

#endif
	return output;
}