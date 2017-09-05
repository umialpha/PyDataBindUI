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
    float4 DownSampleOffsets[16];
    float HorizontalBloomSampleOffsets[5];
    float VerticalBloomSampleOffsets[5];
    int BloomWidth;
};


// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float2 TexCoord0;
	float2 TexCoord1;
	float2 TexCoord2;
	float2 TexCoord3;
	float2 TexCoord4;
	float2 TexCoord5;
	float2 TexCoord6;
	float2 TexCoord7;
};

// VARYING
struct VertexOutputSimple
{
	float4 position [[position]];
	float2 TexCoord0;
};


vertex VertexOutputSimple VSMain(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]]
#endif
	)
{ 
	VertexOutputSimple output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;
	output.TexCoord0 = vData.texcoord0.xy;
#endif
	return output;
}

