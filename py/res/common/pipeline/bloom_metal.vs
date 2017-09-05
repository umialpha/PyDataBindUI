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


vertex VertexOutputSimple FOWMain(
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


vertex VertexOutput DownSamplePass(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{ 
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;
	output.TexCoord0 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[0 ].x, constants.DownSampleOffsets[0 ].y);
	output.TexCoord1 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[3 ].x, constants.DownSampleOffsets[3 ].y);
	output.TexCoord2 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[5 ].x, constants.DownSampleOffsets[5 ].y);
	output.TexCoord3 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[6 ].x, constants.DownSampleOffsets[6 ].y);
	output.TexCoord4 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[9 ].x, constants.DownSampleOffsets[9 ].y);
	output.TexCoord5 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[10 ].x, constants.DownSampleOffsets[10 ].y);
	output.TexCoord6 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[12 ].x, constants.DownSampleOffsets[12 ].y);
	output.TexCoord7 = vData.texcoord0.xy + float2(constants.DownSampleOffsets[15 ].x, constants.DownSampleOffsets[15 ].y);
#endif
	return output;
}
       
vertex VertexOutput HorizontalBlurPass(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;
	float bloomwidth = float(constants.BloomWidth);	
	output.TexCoord0.xy = vData.texcoord0.xy + float2( constants.HorizontalBloomSampleOffsets[0] * bloomwidth, 0.0 );
	output.TexCoord1.xy = vData.texcoord0.xy + float2( constants.HorizontalBloomSampleOffsets[1] * bloomwidth, 0.0 );
	output.TexCoord2.xy = vData.texcoord0.xy + float2( constants.HorizontalBloomSampleOffsets[2] * bloomwidth, 0.0 );
	output.TexCoord3.xy = vData.texcoord0.xy + float2( constants.HorizontalBloomSampleOffsets[3] * bloomwidth, 0.0 );
	output.TexCoord4.xy = vData.texcoord0.xy + float2( constants.HorizontalBloomSampleOffsets[4] * bloomwidth, 0.0 );
#endif
	return output;
}

            

vertex VertexOutput VerticalBlurPass(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;
	float bloomwidth = float(constants.BloomWidth);	
	output.TexCoord0.xy = vData.texcoord0.xy + float2( constants.VerticalBloomSampleOffsets[0] * bloomwidth, 0.0 );
	output.TexCoord1.xy = vData.texcoord0.xy + float2( constants.VerticalBloomSampleOffsets[1] * bloomwidth, 0.0 );
	output.TexCoord2.xy = vData.texcoord0.xy + float2( constants.VerticalBloomSampleOffsets[2] * bloomwidth, 0.0 );
	output.TexCoord3.xy = vData.texcoord0.xy + float2( constants.VerticalBloomSampleOffsets[3] * bloomwidth, 0.0 );
	output.TexCoord4.xy = vData.texcoord0.xy + float2( constants.VerticalBloomSampleOffsets[4] * bloomwidth, 0.0 );
	output.TexCoord5 = vData.texcoord0.xy;
#endif
	return output;
}