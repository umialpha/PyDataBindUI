#include "shaderlib/common.fxl"
#define NEED_GL_BUFFER_SIZE
#include "shaderlib\vardefination.fxl"


#ifndef DECAL_MERGE
#define DECAL_MERGE FALSE
#endif
//宏的默认值
int GlobalParameter : SasGlobal
<
	int3 SasVersion = {1,0,0};
	
	NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
	NEOX_SASEFFECT_MACRO("UnSupported", "DECAL_MERGE", "UnSupported", "FALSE")   
	NEOX_SASEFFECT_SUPPORT_MACRO_END
	
>;


struct VS_INPUT
{
	float4 Pos : POSITION;
};

struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 ScreenPos : TEXCOORD0;
	float3 PosView : TEXCOORD1;
	
#if DECAL_MERGE
	float4 WorldMatInv0:TEXCOORD2;
	float4 WorldMatInv1:TEXCOORD3;
	float4 WorldMatInv2:TEXCOORD4;
	float4 WorldMatInv3:TEXCOORD5;
	float4 UV:			TEXCOORD6;
	float4 Color:		TEXCOORD7;
#endif
};

float4 DecalColor = float4(1,1,1,1);


texture DepthBuffer:DepthBuffer;
sampler sampleDepthBuffer = sampler_state
{
	Texture = (DepthBuffer);
	AddressU = BORDER;
	AddressV = BORDER;
	BorderColor = 0xFFFFFFFF;
	MagFilter = POINT;
	MinFilter = POINT;
	MipFilter = POINT;
};

float alpha_add = 0.0;
float alpha_clamp_range = 1.0;

bool use_separate_alpha_tex
<
	string SasUiLabel = "是否单独的alpha通道";
	string SasUiControl = "BoolPicker";
> = false;
float alpha_tex_u_offset
<
	string SasUiLabel = "alpha通道U偏移";
	string SasUiControl = "FloatPicker";
> = 0.0;
float alpha_tex_v_offset
<
	string SasUiLabel = "alpha通道V偏移";
	string SasUiControl = "FloatPicker";
> = 0.0;
texture separate_alpha_tex
<
	string SasUiLabel = "单独的alpha通道贴图路径";
	string SasUiControl = "TexturePicker";
	string TextureFile = ""; 
>;
sampler SeparateAlphaSampler = sampler_state
{
	Texture = ( separate_alpha_tex );
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};

float4 CameraZPlanes : CameraInfo;
float4x4 mWorldView : WorldView;	
float4x4 mWorldViewProjection : WorldViewProjection;	
float4x4 InverseView: InverseView;
float4x4 InverseWorld: InverseWorld;
float4x4 decal_matrix:InverseWorldView;

VS_OUTPUT vs_main( float4 vPos : POSITION, float4 UV: TEXCOORD0,
					float4 WorldMatInv0: TEXCOORD1, float4 WorldMatInv1: TEXCOORD2, 
					float4 WorldMatInv2: TEXCOORD3, float4 WorldMatInv3: TEXCOORD4,
					float4 Color: TEXCOORD5)
{
    VS_OUTPUT Output = (VS_OUTPUT)0;
  
	float4 vPosWVP = mul(vPos, mWorldViewProjection);
    Output.Position = vPosWVP;
	Output.ScreenPos = vPosWVP;///vPosWVP.w;
	Output.PosView.xyz = mul(vPos, mWorldView).xyz;

#if DECAL_MERGE
	Output.WorldMatInv0 = WorldMatInv0;
	Output.WorldMatInv1 = WorldMatInv1;
	Output.WorldMatInv2 = WorldMatInv2;
	Output.WorldMatInv3 = WorldMatInv3;
	
	Output.UV = UV;
	Output.Color = Color;
#endif
    return Output;    
}

texture decal_map
<
	string SasUiLabel = "贴花"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDecal = sampler_state
{
	Texture	  =	(decal_map);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};
   

float4 TextureTransform0;
float4 blend_op = { 5.0, 2.0, 1.0, 0};

float4 ps_main( VS_OUTPUT In ) : COLOR
{ 
	//计算以左上角为原点的uv
	float2 texcoord = In.ScreenPos.xy/  In.ScreenPos.w * 0.5 + 0.5;
	texcoord.y = 1 - texcoord.y;
	
	float2 geometry_map_bias = 0.5f/GLBufferSize.xy;
	float depth_buffer = 	tex2D(sampleDepthBuffer, texcoord + geometry_map_bias);
	
	float3 pos_view;
	pos_view.z = CameraZPlanes.w / (depth_buffer - CameraZPlanes.z);	
	pos_view.xy = In.PosView.xy / In.PosView.z * pos_view.z;
	
		
	float4 pos_world = mul(float4(pos_view,1), InverseView);	

	
	float4x4 InverseWorldInstance = (float4x4)0;
	
	#if DECAL_MERGE
		InverseWorldInstance[0]= In.WorldMatInv0;
		InverseWorldInstance[1]= In.WorldMatInv1;
		InverseWorldInstance[2]= In.WorldMatInv2;
		InverseWorldInstance[3]= In.WorldMatInv3;
	#else
		InverseWorldInstance = InverseWorld;
	#endif
	

	float4 pos_local = mul(float4(pos_world.xyz,1), InverseWorldInstance);	
	
	if(pos_local.g < -0.5 || pos_local.g > 0.5)
		return 0;
		
	float2 uv = pos_local.rb + 0.5;
	uv.y = 1- uv.y;

	float2 s_uv = saturate(uv);
	if(s_uv.x != uv.x || s_uv.y != uv.y)
		return 0;
	
	float4 transform_uv = TextureTransform0;
	
	#if DECAL_MERGE
		transform_uv = In.UV;
	#endif
	
    s_uv.x = s_uv.x * (transform_uv.y - transform_uv.x) + transform_uv.x;
	s_uv.y = s_uv.y * (transform_uv.w - transform_uv.z) + transform_uv.z;
		
	float4 color = tex2D(SamplerDecal, s_uv);
	float2 alpha_offset = float2(alpha_tex_u_offset, alpha_tex_v_offset);
	if(use_separate_alpha_tex)
	{
		color.a = tex2D(SeparateAlphaSampler, s_uv + alpha_offset);
	}
	else
	{
		color.a = tex2D(SamplerDecal, s_uv + alpha_offset).a;
	}
	
	color *= blend_op[2];
	
	#if DECAL_MERGE
		float4 decal_color = In.Color;
	#else
		float4 decal_color = DecalColor;
	#endif
	
	color *=  decal_color;
	//alpha效果
	color.a = min(color.a, 1.0);
	float re = color.a + alpha_add;
	re = clamp(re, 0.0, alpha_clamp_range);
	color.a = re / alpha_clamp_range;
	return color ;
}



technique TShader
<
	string Description = "普通单层贴图";
>
{
	pass p0
	{	
		CullMode = CCW;
		
		ZENABLE = TRUE;
		
		ZFUNC = Greater;
		ZWriteEnable = FALSE;
			
		AlphaBlendEnable = TRUE;
		
		SrcBlend         = blend_op[0];
		DestBlend        = blend_op[1];
		
		AlphaTestEnable = true;
		AlphaRef = 0;
		AlphaFunc = Greater;
		
		StencilEnable = true;
		StencilRef =  0x80;	//用到了stencil的最高位
        StencilMask = 0x80;
		StencilFunc = NOTEQUAL;
		
		
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}
