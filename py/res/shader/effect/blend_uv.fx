
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


float4x4 TexTransMatrix0: TexTransform0;
float4x4 TexTransMatrix1: TexTransform1;
float4x4 WorldViewProj	: WorldViewProjection;
float4x4 WorldViewMatrix: WorldView;

float4 blend_color = float4(1,1,1,1);

float scale_x
<
	string SasUiLabel = "scale_x";
	string SasUiControl = "FloatPicker";
> = 1.0;

float scale_y
<
	string SasUiLabel = "scale_y";
	string SasUiControl = "FloatPicker";
> = 1.0;

float offset_x
<
	string SasUiLabel = "offset_x";
	string SasUiControl = "FloatPicker";
> = 0;

float offset_y
<
	string SasUiLabel = "offset_x";
	string SasUiControl = "FloatPicker";
> = 0;

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
	Out.tex0.xy += float2(offset_x, offset_y);
	Out.tex0.xy *= float2(scale_x, scale_y);
	Out.point_color = In.point_color;
	return Out;
}

float4 PS_main( VS_Out In): COLOR
{
	float4 texcolor = tex2D(Tex0, In.tex0.xy);
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

technique TShaderModulate
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