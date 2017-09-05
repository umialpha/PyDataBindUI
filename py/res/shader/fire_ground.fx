#include "common_defination.fx"
#include "shaderlib/common.fxl"

#define SHADE_MODE SHADE_PHONG

float FrameTime : FrameTime;

//宏的默认值
int GlobalParameter : SasGlobal
<
	int3 SasVersion = {1,0,0};
	string SasEffectAuthoring = "hzchengbingfei";
	string SasEffectCategory = "h30";
	string SasEffectCompany = "Netease";
	string SasEffectDescription = "瀑布用的effect";

	NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
	NEOX_SASEFFECT_MACRO("是否高光", "NEOX_SPECULAR_ENABLE", "BOOL", "FALSE")  
	NEOX_SASEFFECT_MACRO("是否高光遮罩", "NEOX_SPECULAR_MASK_ENABLE", "BOOL", "FALSE") 

	//普通物体会有的
	NEOX_SASEFFECT_MACRO("UnSupported", "GPU_SKIN_ENABLE", "UnSupported", "FALSE") 
	NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
	NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
	NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "FALSE")  
	NEOX_SASEFFECT_SUPPORT_MACRO_END

	NEOX_SASEFFECT_ATTR_BEGIN
	NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "FALSE")
	NEOX_SASEFFECT_ATTR_END
>;

texture	Tex0
<
	string SasUiLabel = "遮罩贴图";
	string SasUiControl = "FilePicker";
>;

sampler	SamplerMask = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

texture	Tex1
<
	string SasUiLabel = "扰动贴图";
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDistortion = sampler_state
{
	Texture	  =	(Tex1);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

texture	Tex3
<
	string SasUiLabel = "纹理贴图";
	string SasUiControl = "FilePicker";
>;

sampler	SamplerAlbedo = sampler_state
{
	Texture	  =	(Tex3);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

float Speed
<
	string SasUiLabel = "Speed";
	string SasUiControl = "FloatPicker";
> = 2.0f;

float Intensity
<
	string SasUiLabel = "Intensity";
	string SasUiControl = "FloatPicker";
> = 4.0f;

float4 Color
<
	string SasUiLabel = "Fire Color";
	string SasUiControl = "ColorPicker";
> = float4(0.99, 0.47, 0.235, 1.0);

//自定义部分
#define CUSTOM_EMISSIVE_MTL
#define CUSTOM_OPACITY

// #define AMBIENT_COLOR_ENABLE FALSE

#define FOG_TYPE FOG_TYPE_HEIGHT
#define FOG_ENABLE TRUE

#include "shaderlib/pixellit.tml"

float GetCycleValue(float x)
{
	return sin(x) * 0.5 * 3.1415;
}

float GetDistortUV(PS_GENERAL ps_general, float speed)
{
	float4 distort_map = tex2D(SamplerDistortion, ps_general.RawTexCoord0.xy);
	float cycle_time = FrameTime * speed;
	float3 cycle_array = float3(GetCycleValue(cycle_time + 4.0), GetCycleValue(cycle_time + 0.0), GetCycleValue(cycle_time + 2.0));
	float uv = dot(distort_map.xyz, cycle_array);
	return uv;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	float uv = GetDistortUV(ps_general, Speed);
	float4 albedo = tex2D(SamplerAlbedo, float2(uv, 1.0 - uv));
	float3 emissive = albedo.rgb * Intensity * Color.rgb;
	return emissive;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float4 mask_color = tex2D(SamplerMask, ps_general.RawTexCoord0.xy);
	float uv = GetDistortUV(ps_general, Speed);
	return (1.0 - uv) * mask_color.a;
}

technique TShader
<
	string Description = "瀑布用的effect";
>
{
	pass p0
	{	
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}
