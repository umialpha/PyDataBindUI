
//#define NEED_TEX_TRANSFORM0
//#define NEED_TEX_TRANSFORM1

sampler Tex0 = sampler_state
{
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	//AddressU = CLAMP;
	//AddressV = CLAMP;
	//MipMapLodBias = -2.5f;
};

texture	turbulence1
<
	string SasUiLabel = "偏移贴图1"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture	  =	(turbulence1);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
	MipMapLodBias = -0.5f;
};

texture	turbulence2
<
	string SasUiLabel = "偏移贴图2"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse2 = sampler_state
{
	Texture	  =	(turbulence2);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
	MipMapLodBias = -0.5f;
};

float4x4 TexTransMatrix0: TexTransform0;
float4x4 TexTransMatrix1: TexTransform1;
float4x4 WorldViewProj	: WorldViewProjection;
float4x4 WorldViewMatrix: WorldView;

float4 blend_color = float4(1,1,1,1);

float3 vx_vy_scale1
<
	string SasUiLabel = "vx_vy_scale1"; 
> = float3(0.0, 0.0, 1.0);

float3 vx_vy_scale2
<
	string SasUiLabel = "vx_vy_scale2"; 
> = float3(0.0, 0.0, 1.0);

float amplitude1
<
	string SasUiLabel = "振幅1";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 10.0f;
	float SasUiSteps = 0.1f;
> = 0.1;

float amplitude2
<
	string SasUiLabel = "振幅2";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 10.0f;
	float SasUiSteps = 0.1f;
> = 0.1;

float4 blend_op = { 5.0, 2.0, 1.0, 0};

struct OneTexPoint { 
	float4 pos			: POSITION;
	float4 point_color	: COLOR;
	float4 tex0			: TEXCOORD0;
}; 

struct VS_Out { 
	float4 pos			: POSITION;
	float4 point_color	: COLOR;
	float4 tex0			: TEXCOORD0; 
	float4 tex1			: TEXCOORD1; 
	float4 tex2			: TEXCOORD2; 
}; 

float Time : FrameTime;

VS_Out VS_main( OneTexPoint In )
{
	VS_Out Out = (VS_Out)0;
	Out.pos = mul(In.pos, WorldViewProj);
	Out.tex0.xyz = mul(float3(In.tex0.xy,1), (float3x3)TexTransMatrix0);
	Out.tex1.xy = In.tex0.xy * vx_vy_scale1.z + vx_vy_scale1.xy * Time;
	Out.tex2.xy = In.tex0.xy * vx_vy_scale2.z + vx_vy_scale2.xy * Time;
	Out.point_color = In.point_color;
	return Out;
}

float4 PS_main( VS_Out In): COLOR
{
	float4 tex1 = tex2D(SamplerDiffuse1, In.tex1.xy) - 0.5;
	float4 tex2 = tex2D(SamplerDiffuse2, In.tex2.xy) - 0.5;
	float4 texcolor = tex2D(Tex0, In.tex0.xy + tex1.xy * amplitude1 + tex2.xy * amplitude2);
	texcolor *= In.point_color;
	return texcolor;
}

technique TShader
{
	pass P0
	{
		ZWriteEnable = FALSE;
		CullMode = None;
		AlphaBlendEnable = TRUE;
		SrcBlend = blend_op[0];
		DestBlend = blend_op[1];
		
		Sampler[0] = (Tex0);
		
		VertexShader = compile vs_2_0 VS_main();
		PixelShader = compile ps_2_0 PS_main(); 
	}	
}