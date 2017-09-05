//粒子和贴花的通用tech

//hsv变色支持
#include "../pipeline/shaderlib/common.fxl"
float hsv_offset_A = 0.25;//饱和度
float hsv_offset_I = 0.0;//明度
bool hsv_change_h = true;//直接改变为hsv_offset_H值，而不是偏移

//变色开关
#define USE_HSV_OFFSET_TRUE				1
#define USE_HSV_OFFSET_FALSE			2
//宏的默认值
int GlobalParameter : SasGlobal
<
	int3 SasVersion = {1,0,0};
	
	NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN  
	NEOX_SASEFFECT_MACRO("UnSupported", "USE_HSV_OFFSET_SWITCH", "UnSupported", "USE_HSV_OFFSET_FALSE")  
	NEOX_SASEFFECT_SUPPORT_MACRO_END
>;

sampler TexClamp = sampler_state//贴花
{
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	//MipMapLodBias = -2.5f;
};

sampler TexRepeat = sampler_state//彩带/粒子
{
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	//AddressU = WRAP;
	//AddressV = WRAP;
	//MipMapLodBias = -2.5f;
};

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

bool FogAffected = true;//自身的雾效开关
//雾效支持
#define NEED_FOG_COLOR
#define NEED_FOG_ENABLE
#define NEED_FOG_INFO
#include "../pipeline/shaderlib/vardefination.fxl"
#include "../pipeline/shaderlib/fog.fxl"

float4x4 TexTransMatrix0: TexTransform0;
//float4x4 TexTransMatrix1: TexTransform1;
float4x4 WorldViewProj	: WorldViewProjection;
float4x4 ViewProjMatrix: ViewProjection;
float4x4 WorldMatrix: World ;

float4 blend_color = float4(1,1,1,1);
float4 texuv_clamp
<
	string SasUiLabel = "UV范围，超出范围变为透明"; 
> = float4(0,0,1,1);
float4 blend_op = { 5.0, 2.0, 1.0, 0};

float alpha_add = 0.0;
float alpha_clamp_range = 1.0;

struct OneTexPoint { 
	float4 pos			: POSITION;
	float4 point_color	: COLOR;
	float4 tex0			: TEXCOORD0; 
	
	float fog_intensity	: TEXCOORD4;
}; 
struct TwoTexPoint { 
	float4 pos			: POSITION;
	float4 point_color	: COLOR1;
	float4 blend_color	: COLOR0;
	float4 tex0			: TEXCOORD0;
	float4 tex1			: TEXCOORD1;
	
	float fog_intensity	: TEXCOORD4;
}; 

OneTexPoint VS_OneTex(OneTexPoint In)
{
	OneTexPoint Out = (OneTexPoint)0;
	Out.pos = mul(In.pos, WorldViewProj);
	Out.tex0.xyz = mul(float3(In.tex0.xy,1), (float3x3)TexTransMatrix0);
	
	Out.point_color = In.point_color;
	Out.fog_intensity = GetHeightFog(FogEnable && FogAffected, FogInfo, mul(In.pos, WorldMatrix), Out.pos);
	return Out;
}

TwoTexPoint VS_TwoTex(TwoTexPoint In)
{
	TwoTexPoint Out = (TwoTexPoint)0;
	Out.pos = mul(In.pos, WorldViewProj);
	Out.tex0.xyz = mul(float3(In.tex0.xy,1), (float3x3)TexTransMatrix0);
	Out.tex1.xyz = float3(In.tex1.xy,1);//mul(float3(In.tex1.xy,1), (float3x3)TexTransMatrix1);
	Out.point_color = In.point_color;
	Out.blend_color = In.blend_color;
	
	Out.fog_intensity = GetHeightFog(FogEnable && FogAffected, FogInfo, mul(In.pos, WorldMatrix), Out.pos);
	return Out;
}

OneTexPoint VS_DecalOneTex(OneTexPoint In)
{
	OneTexPoint Out = (OneTexPoint)0;
	Out.pos = mul(In.pos, WorldViewProj);
	Out.tex0 = mul( In.pos, TexTransMatrix0);
	Out.point_color = In.point_color;
	
	Out.fog_intensity = GetHeightFog(FogEnable && FogAffected, FogInfo, mul(In.pos, WorldMatrix), Out.pos);
	return Out;
}

float4 PS_OneTex( OneTexPoint In): COLOR
{
	float2 alpha_offset = float2(alpha_tex_u_offset, alpha_tex_v_offset);
	float4 texcolor = tex2D(TexRepeat, In.tex0.xy);
	if(use_separate_alpha_tex)
	{
		texcolor.a = tex2D(SeparateAlphaSampler, In.tex0.xy + alpha_offset);
	}
	else
	{
		texcolor.a = tex2D(TexRepeat, In.tex0.xy + alpha_offset).a;
	}
	texcolor *= blend_op[2];
	if(blend_op[3] == 0)
	{
#if EQUAL(USE_HSV_OFFSET_SWITCH, USE_HSV_OFFSET_FALSE)
		texcolor *= In.point_color;
#else
		float gray = texcolor.r * 0.299 + texcolor.g * 0.587 + texcolor.b * 0.114;
		gray += hsv_offset_I;
		gray = saturate(gray);
		float s = (0.5-abs(gray - 0.5))*2.0 * hsv_offset_A;
		if (hsv_offset_A > 0.5)
		{
			gray += (hsv_offset_A-0.5) * s;
		}
		float3 p_hsv = rgb_to_hsv(In.point_color.rgb);
		float3 hsv = float3(p_hsv.x, s, gray);
		if(!hsv_change_h)
		{
			float3 temp = rgb_to_hsv(texcolor.rgb);
			hsv.x += temp.x;
			hsv.x = fmod(hsv.x, 1.0);
		}
		texcolor.rgb = hsv_to_rgb(hsv);
		texcolor.a *= In.point_color.a;
#endif
	}else
	{
		texcolor += In.point_color;
	}
	
	if (blend_op[0] == 5.0 && blend_op[1] == 6.0)
	{
		//雾效
		texcolor.rgb = texcolor.rgb * (1.0-In.fog_intensity) + FogColor * In.fog_intensity;
	}
	
	//alpha效果
	texcolor.a = min(texcolor.a, 1.0);
	float re = texcolor.a + alpha_add;
	re = clamp(re, 0.0, alpha_clamp_range);
	texcolor.a = re / alpha_clamp_range;
	
	return texcolor;
}

float4 PS_TwoTex( TwoTexPoint In): COLOR
{
	float4 texcolor1 = tex2D(TexRepeat, In.tex0.xy);
	float4 texcolor2 = tex2D(TexRepeat, In.tex1.xy);
	texcolor1 = texcolor1 * In.blend_color.a + texcolor2 * (1.0-In.blend_color.a);
	
	texcolor1 *= blend_op[2];
	
	if(blend_op[3] == 0)
	{
#if EQUAL(USE_HSV_OFFSET_SWITCH, USE_HSV_OFFSET_FALSE)
		texcolor1 *= In.point_color;
#else
		float gray = texcolor1.r * 0.299 + texcolor1.g * 0.587 + texcolor1.b * 0.114;
		gray += hsv_offset_I;
		gray = saturate(gray);
		float s = (0.5-abs(gray - 0.5))*2.0 * hsv_offset_A;
		if (hsv_offset_A > 0.5)
		{
			gray += (hsv_offset_A-0.5) * s;
		}
		float3 p_hsv = rgb_to_hsv(In.point_color.rgb);
		float3 hsv = float3(p_hsv.x, s, gray);
		if(!hsv_change_h)
		{
			float3 temp = rgb_to_hsv(texcolor1.rgb);
			hsv.x += temp.x;
			hsv.x = fmod(hsv.x, 1.0);
		}
		texcolor1.rgb = hsv_to_rgb(hsv);
		texcolor1.a *= In.point_color.a;
#endif
	}else
	{
		texcolor1 += In.point_color;
	}
	
	if (blend_op[0] == 5.0 && blend_op[1] == 6.0)
	{
		//雾效
		texcolor1.rgb = texcolor1.rgb * (1.0-In.fog_intensity) + FogColor * In.fog_intensity;
	}
	
	//alpha效果
	texcolor1.a = min(texcolor1.a, 1.0);
	float re = texcolor1.a + alpha_add;
	re = clamp(re, 0.0, alpha_clamp_range);
	texcolor1.a = re / alpha_clamp_range;
	
	return texcolor1;
}

float4 PS_DecalOneTex( OneTexPoint In): COLOR
{
	float4 texcolor = float4(0,0,0,0);
	if(blend_op[3] != 0)
	{
		texcolor = float4(1,1,1,0);
	}
	
	if (In.tex0.x >= texuv_clamp.x && In.tex0.x <= texuv_clamp.z && 
		In.tex0.y >= texuv_clamp.y && In.tex0.y <= texuv_clamp.w)
	{
		texcolor = tex2D(TexClamp, In.tex0.xy / In.tex0.w);
		float2 alpha_offset = float2(alpha_tex_u_offset, alpha_tex_v_offset);
		if(use_separate_alpha_tex)
		{
			texcolor.a = tex2D(SeparateAlphaSampler, In.tex0.xy + alpha_offset);
		}
		else
		{
			texcolor.a = tex2D(TexClamp, In.tex0.xy + alpha_offset).a;
		}
		texcolor *= blend_op[2];
		
		if(blend_op[3] == 0)
		{
#if EQUAL(USE_HSV_OFFSET_SWITCH, USE_HSV_OFFSET_FALSE)
		texcolor *= blend_color;
#else
		float gray = texcolor.r * 0.299 + texcolor.g * 0.587 + texcolor.b * 0.114;
		gray += hsv_offset_I;
		gray = saturate(gray);
		float s = (0.5-abs(gray - 0.5))*2.0 * hsv_offset_A;
		if (hsv_offset_A > 0.5)
		{
			gray += (hsv_offset_A-0.5) * s;
		}
		float3 p_hsv = rgb_to_hsv(blend_color.rgb);
		float3 hsv = float3(p_hsv.x, s, gray);
		if(!hsv_change_h)
		{
			float3 temp = rgb_to_hsv(texcolor.rgb);
			hsv.x += temp.x;
			hsv.x = fmod(hsv.x, 1.0);
		}
		texcolor.rgb = hsv_to_rgb(hsv);
		texcolor.a *= blend_color.a;
#endif
		}else
		{
			texcolor += blend_color;
		}
		texcolor *= blend_color;
	}
	
	if (blend_op[0] == 5.0 && blend_op[1] == 6.0)
	{
		//雾效
		texcolor.rgb = texcolor.rgb * (1.0-In.fog_intensity) + FogColor * In.fog_intensity;
	}
	
	//alpha效果
	texcolor.a = min(texcolor.a, 1.0);
	float re = texcolor.a + alpha_add;
	re = clamp(re, 0.0, alpha_clamp_range);
	texcolor.a = re / alpha_clamp_range;
	
	return texcolor;
}

technique TOneTex
{
	pass P0
	{
		ZWriteEnable = FALSE;
		CullMode = None;
		AlphaBlendEnable = TRUE;
		SrcBlend = blend_op[0];
		DestBlend = blend_op[1];
		
		Sampler[0] = (TexRepeat);
		
#if EQUAL(USE_HSV_OFFSET_SWITCH, USE_HSV_OFFSET_FALSE)
		VertexShader = compile vs_2_0 VS_OneTex();
		PixelShader = compile ps_2_0 PS_OneTex(); 
#else
		VertexShader = compile vs_3_0 VS_OneTex();
		PixelShader = compile ps_3_0 PS_OneTex(); 
#endif
	}
}

technique TTwoTex
{
	pass P0
	{
		ZWriteEnable = FALSE;
		CullMode = None;
		AlphaBlendEnable = TRUE;
		SrcBlend = blend_op[0];
		DestBlend = blend_op[1];
		
		Sampler[0] = (TexRepeat);

#if EQUAL(USE_HSV_OFFSET_SWITCH, USE_HSV_OFFSET_FALSE)
		VertexShader = compile vs_2_0 VS_TwoTex();
		PixelShader = compile ps_2_0 PS_TwoTex(); 
#else
		VertexShader = compile vs_3_0 VS_TwoTex();
		PixelShader = compile ps_3_0 PS_TwoTex(); 
#endif
	}
}
//---------------------------------------------------------------------------
technique TDecalOneTex
{
	pass P0
	{
		ZWriteEnable = FALSE;
		CullMode = None;
		DepthBias = -0.000024;
		AlphaBlendEnable = TRUE;
		SrcBlend = blend_op[0];
		DestBlend = blend_op[1];
		
		Sampler[0] = (TexClamp);

#if EQUAL(USE_HSV_OFFSET_SWITCH, USE_HSV_OFFSET_FALSE)
		VertexShader = compile vs_2_0 VS_DecalOneTex();
		PixelShader = compile ps_2_0 PS_DecalOneTex(); 
#else
		VertexShader = compile vs_3_0 VS_DecalOneTex();
		PixelShader = compile ps_3_0 PS_DecalOneTex(); 
#endif
	}
}

//---------------------------------------------------------------------------
float4 PS_Wareframe( OneTexPoint In): COLOR
{
	float4 texcolor = float4(0.8,0.8,0.8,0.8);
	return texcolor;
}
technique TWareframe
{
	pass P0
	{
		ZWriteEnable = FALSE;
		CullMode = None;
		FillMode = WIREFRAME;
		
		AlphaBlendEnable = TRUE;
		SrcBlend = blend_op[0];
		DestBlend = blend_op[1];
		
		VertexShader = compile vs_3_0 VS_OneTex();
		PixelShader = compile ps_3_0 PS_Wareframe(); 
	}
}

//--------------------------------------------------------------------------------------
float4 PS_Overdraw( OneTexPoint In): COLOR
{
	float4 texcolor = float4(0.10546875,0.05859375,0.03125, 1.0);
	return texcolor;
}
technique TOverdraw
{
	pass P0
	{
		ZWriteEnable = FALSE;
		CullMode = None;
		
		AlphaBlendEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = ONE;
		
		VertexShader = compile vs_3_0 VS_OneTex();
		PixelShader = compile ps_3_0 PS_Overdraw(); 
	}
}