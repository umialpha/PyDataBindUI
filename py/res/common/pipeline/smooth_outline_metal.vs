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
    float4 rtSize;
    float horBlurGaussOffset[5];
    float verBlurGaussOffset[5];
    float width;
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
};

vertex VertexOutput VerBlurVS(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;

	float pixelSize = constants.rtSize.w;
	float blurWidth = pixelSize * constants.width;
	output.TexCoord0 = vData.texcoord0.xy + float2(0.0,blurWidth * constants.horBlurGaussOffset[0]);	
	output.TexCoord1 = vData.texcoord0.xy + float2(0.0,blurWidth * constants.horBlurGaussOffset[1]);
	output.TexCoord2 = vData.texcoord0.xy + float2(0.0,blurWidth * constants.horBlurGaussOffset[2]);
	output.TexCoord3 = vData.texcoord0.xy + float2(0.0,blurWidth * constants.horBlurGaussOffset[3]);
	output.TexCoord4 = vData.texcoord0.xy + float2(0.0,blurWidth * constants.horBlurGaussOffset[4]);
#endif
	return output;
}


vertex VertexOutput HorBlurVS(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;

	float pixelSize = constants.rtSize.z;
	float blurWidth = pixelSize * constants.width;
	output.TexCoord0 = vData.texcoord0.xy + float2(blurWidth * constants.horBlurGaussOffset[0], 0.0);	
	output.TexCoord1 = vData.texcoord0.xy + float2(blurWidth * constants.horBlurGaussOffset[1], 0.0);
	output.TexCoord2 = vData.texcoord0.xy + float2(blurWidth * constants.horBlurGaussOffset[2], 0.0);
	output.TexCoord3 = vData.texcoord0.xy + float2(blurWidth * constants.horBlurGaussOffset[3], 0.0);
	output.TexCoord4 = vData.texcoord0.xy + float2(blurWidth * constants.horBlurGaussOffset[4], 0.0);
#endif
	return output;
}

vertex VertexOutput BlendVS(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;
	output.TexCoord0 = vData.texcoord0.xy;
#endif
	return output;
}