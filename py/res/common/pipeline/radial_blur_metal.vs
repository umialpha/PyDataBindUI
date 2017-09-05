using namespace metal;


#ifndef NEOX_METAL_NO_ATTR
//ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];
};
#endif


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

// UNIFORM
struct VSConstants
{
    float radial_center_u;
    float radial_center_v;
    float fSampleDist;
};

vertex VertexOutput VSMain(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = vData.position;

   // 0.5,0.5 is the center of the screen   
   // so substracting uv from it will result in   
   // a vector pointing to the middle of the screen   
	float2 dir = float2(constants.radial_center_u, constants.radial_center_v) - vData.texcoord0.xy;  

   // calculate the distance to the center of the screen   
   float dist = length(dir);  
   // normalize the direction (reuse the distance)   
   dir /= dist;  
     
	output.TexCoord0 = vData.texcoord0.xy;
	output.TexCoord1 = vData.texcoord0.xy + dir * -0.08 * constants.fSampleDist;
	output.TexCoord2 = vData.texcoord0.xy + dir * -0.05 * constants.fSampleDist;
	output.TexCoord3 = vData.texcoord0.xy + dir * -0.02 * constants.fSampleDist;
	output.TexCoord4 = vData.texcoord0.xy + dir * -0.01 * constants.fSampleDist;
	output.TexCoord5 = vData.texcoord0.xy + dir * 0.02 * constants.fSampleDist;
	output.TexCoord6 = vData.texcoord0.xy + dir * 0.05 * constants.fSampleDist;
	output.TexCoord7 = vData.texcoord0.xy + dir * 0.08 * constants.fSampleDist;
#endif
	return output;
}