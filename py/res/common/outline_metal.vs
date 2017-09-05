using namespace metal;

#ifndef NEOX_METAL_NO_ATTR
//ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];
};
#endif

// UNIFORM
struct VSConstants
{
    float4x4 wvp;
};

// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float4 TexCoord0;
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
	output.TexCoord0 = vData.texcoord0;
#endif
	return output;
}