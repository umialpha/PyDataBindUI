using namespace metal;

#ifndef NEOX_METAL_NO_ATTR
//ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 texcoord1 [[attribute(TEXTURE1)]];
	float4 texcoord2 [[attribute(TEXTURE2)]];
};
#endif


// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float2 Tex0;
	float2 View;
	float2 View2;
};


vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]]
#endif
	)
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;
	output.Tex0 = vData.texcoord0.xy;
	output.View = vData.texcoord1.xy;
	output.View2 = vData.texcoord2.xy;
#endif
	return output;
}
