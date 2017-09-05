using namespace metal;

// ATTRIBUTE
struct VertexInput
{	
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 position [[attribute(POSITION)]];
};


// UNIFORM
struct VSConstants
{
	float4x4 wvp;
};


// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float4 RAWUV0;
	
};

vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput  vData [ [stage_in] ],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = (constants.wvp * vData.position);
	output.RAWUV0 = vData.texcoord0;
#endif
	return output;
}