#define LIT_ENABLE 0

#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define SHADE_MODE SHADE_PHONG
//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "jwh,hzwangchao2014";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "英雄通用材质";

  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("粗糙度区分", "GLOSS_ENABLE", "BOOL", "TRUE")
  NEOX_SASEFFECT_MACRO("金属度区分", "MENTAL_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("使用溶解效果", "DISSOLVE_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("使用法线贴图", "NORMAL_MAP_ENABLE", "BOOL", "FALSE")
  
  //普通物体会有的
  NEOX_SASEFFECT_MACRO("UnSupported", "GPU_SKIN_ENABLE", "UnSupported", "FALSE") 
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "TRUE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "FOG_ENABLE", "UnSupported", "FALSE")
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END  
>;

#define LIGHT_MAP_ENABLE TRUE

texture	Tex0
<
	string SasUiLabel = "颜色贴图"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

float matcap_brightness
<
	string SasUiLabel = "环境光强度"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "8.0";
> = 1;
texture	TexMatcap1
<
	string SasUiLabel = "MatCap"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerMatCap = sampler_state
{
	Texture	  =	(TexMatcap1);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};
float4 ExtraRimColor
<
	string SasUiLabel = "爆气颜色";
	string SasUiControl = "ColorPicker";
> = float4(0.0, 0.0, 0.0, 1.0);

#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE TRUE
#define FOG_TYPE FOG_TYPE_HEIGHT

// #define FOG_ENABLE 0
#ifndef FOG_ENABLE
#define FOG_ENABLE FALSE
#endif

#define LIGHT_MAP_ENABLE 0

//自定义部分
//#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
//#define NEED_OPACITY_MTL
#define CUSTOM_EMISSIVE_MTL

#include "shaderlib/pixellit.tml"
const float4 camera_pos:CameraPosition;
#if DISSOLVE_ENABLE
//Dissolve Textures
texture TexDissolve3
<
	string SasUiLabel = "溶解贴图"; 
	string SasUiControl = "FilePicker"; 
>;
sampler SamplerDissolve3 = sampler_state
{
	Texture	  =	(TexDissolve3);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
//Dissolve Variables
float4 Dissolve_color 
<
	string SasUiLabel = "溶解颜色"; 
	string SasUiControl = "ColorPicker";
>  = float4(1.0, 1.0, 1.0, 1.0);
float Dissolve_color_intensity
<
	string SasUiLabel = "溶解颜色强度"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "10.0";
> = 2.0;
float Dissolve_intensity
<
	string SasUiLabel = "溶解强度"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "-1.0";
	string SasUiMax = "1.0";
> = -0.05;
#endif
#if DISSOLVE_ENABLE
//////////////////////////////////////////////////////////////////////
//
//	溶解效果获取函数
//		溶解使用采样贴图的方式来实现,用一张深度贴图来采样另外一张贴图的通道的方式来实现边缘效果,
//		这样方便做出不同程度的边缘及边缘宽度
//	返回float3类型为最终rgb颜色
///////////////////////////////////////////////////////////////////////
float3 GetDissolveAttribute(PS_GENERAL ps_general){
	float3 dissolve_color = 0.0;
	//Dissolve
	//取溶解效果贴图
	dissolve_color = tex2D(SamplerDissolve3,ps_general.TexCoord0.xy).x;
	//添加可控制的溶解参数混合
	dissolve_color -= Dissolve_intensity ;
	dissolve_color = saturate(dissolve_color);
	//通过溶解效果贴图来采样溶解控制图,获取最终的溶解状态,g通道控制溶解边缘及样式,b通道控制边缘描边宽度
	float3 dissolve_attribute = tex2D(SamplerDissolve3, dissolve_color.rg).y ;
	dissolve_attribute.g = 1.0f - dissolve_attribute.y;
//	dissolve_attribute = saturate(dissolve_attribute);	
	return dissolve_attribute;
}
#endif
//////////////////////////////////////////////////////////////////////
//
//	透明函数
//		将自发光效果 * 溶解效果 * 控制图
//	返回float
///////////////////////////////////////////////////////////////////////
float GetOpacity(PS_GENERAL ps_general)
{
	//base attributes
	float result = 1.0;
	//Dissolve
	float alpha = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy).a;
#if DISSOLVE_ENABLE
	float dissolve_alpha = GetDissolveAttribute(ps_general).y;	
	result = alpha * dissolve_alpha;
#else
	result = alpha;
#endif
	return result;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	//vectors
	float3 normal = ps_general.NormalWorld;
	float3 tangent = ps_general.TangentWorld;
	float3 binormal = ps_general.BinormalWorld;
	float3 normal_world = float3(0,0,1);
	float3 normal_view = 0.0;
	float3 view = camera_pos.xyz - ps_general.PosWorld.xyz;
	//K
	//textures
	//diffuse
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	//normal
	float2 normal_offset = tex2D(sampleNORMAL,ps_general.TexCoord0.xy).xy;
	normal_offset = normal_offset * 2.0 - 1.0;
	normal_world.xy = normal_offset ;
	normal_world = normal_world.x * tangent + normal_world.y * binormal + normal_world.z * normal;
	normal_world = normalize(normal_world);
	//matcap
	normal_view = mul(normal_world,(float3x3)ViewMatrix).xyz;
	normal_view.y = -normal_view.y;
	float gloss = tex2D( sampleNORMAL, ps_general.TexCoord0.xy).z;
	normal_view.xy = normal_view.xy * 0.5 + 0.5;
	float3 matcap = 0.0;
#if GLOSS_ENABLE
	float mip = (1 - gloss) * 8 ;
	matcap = tex2Dlod(SamplerMatCap, float4(normal_view.xy, 0, mip)).xyz;
#else
	matcap = 0.0;
#endif
	matcap *= matcap_brightness;
	float3 result = 0;
#if MENTAL_ENABLE
	float mental = 0.0;
	mental = tex2D(sampleNORMAL,ps_general.TexCoord0.xy).w;
	result = diffuse_map_color * (1.0 - mental) + matcap  * diffuse_map_color.rgb * gloss * mental  ;
#else
	result = diffuse_map_color.rgb + matcap * gloss ;
#endif
#if DISSOLVE_ENABLE
	//Dissolve
	float3 dissolve_intensity = GetDissolveAttribute(ps_general).r;
	result = result.rgb + Dissolve_color.rgb * Dissolve_color_intensity * dissolve_intensity;
#endif
	return result;
}

technique TShader
<
	string Description = "英雄溶解材质";
>
{
	pass p0
	{	
	//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

