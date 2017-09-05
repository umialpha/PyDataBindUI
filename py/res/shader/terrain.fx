#include "common_defination.fx"
#include "shaderlib/common.fxl"


//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "lzb";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "地形用到的effect";
    //地形专属
  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("UnSupported", "TERRAIN_TECH_TYPE", "UnSupported", "TERRAIN_SINGLE_LAYER") 
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "FALSE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_SUPPORT_MACRO_END
>;

//todo:现在是依靠sampler的出现顺序来确定寄存器布局，不确定每台机器都表现一致

sampler samp_color0 = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler samp_color1 = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler samp_blend0  = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

sampler samp_color2 = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler samp_blend1 = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

sampler samp_color3 = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler samp_blend2 = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

sampler samp_lightmap  = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
                 

#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE FALSE
#define FOG_TYPE FOG_TYPE_HEIGHT

//受雾影响和normalmap都应该是场景设的，暂时放这吧
#define FOG_ENABLE TRUE
//自定义部分
#define CUSTOM_DIFFUSE_MTL


#include "shaderlib/pixellit.tml"

float4 uv_transform;
float3 BlendColor(float3 color0, float3 color1, float factor)
{
	return  color0 * (1 - factor) + color1 * factor;
}

float3 GetDiffuseMtl(PS_GENERAL ps_general)
{
	float blend_factor0 = tex2D(samp_blend0, ps_general.RawTexCoord0.xy).a;//
	float blend_factor1 = tex2D(samp_blend1, ps_general.RawTexCoord0.xy).a;//
	float blend_factor2 = tex2D(samp_blend2, ps_general.RawTexCoord0.xy).a;//
	

	float4 diffuse_map_color0 = tex2D(samp_color0, ps_general.RawTexCoord0.xy * uv_transform[0]);
	float4 diffuse_map_color1 = tex2D(samp_color1, ps_general.RawTexCoord0.xy * uv_transform[1]);
	float4 diffuse_map_color2 = tex2D(samp_color2, ps_general.RawTexCoord0.xy * uv_transform[2]);
	float4 diffuse_map_color3 = tex2D(samp_color3, ps_general.RawTexCoord0.xy * uv_transform[3]);	
////////
/*
	float blend_factor0 = tex2D(samp_blend0, ps_general.TexCoord0.xy).a;
	float blend_factor1 = tex2D(samp_blend1, ps_general.TexCoord0.xy).a;
	float blend_factor2 = tex2D(samp_blend2, ps_general.TexCoord0.xy).a;
	
	float3 diffuse_map_color0 = tex2D(samp_color0, ps_general.TexCoord1.xy).xyz;
	float3 diffuse_map_color1 = tex2D(samp_color1, ps_general.TexCoord1.xy).xyz;
	float3 diffuse_map_color2 = tex2D(samp_color2, ps_general.TexCoord1.xy).xyz;
	float3 diffuse_map_color3 = tex2D(samp_color3, ps_general.TexCoord1.xy).xyz;	
	
	float3 light_map_color = tex2D(samp_lightmap, ps_general.TexCoord0.xy).xyz;
	*/
	
///此处开始分支	
	float3 result = float3(1.0, 1.0, 1.0);
#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_VCOLOR)
	result = diffuse_map_color0;
#endif


#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_VCOLOR_LIGHTMAP)
	result = diffuse_map_color0;
#endif


#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_SINGLE_LAYER)
	result = diffuse_map_color0;
#endif

#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_SINGLE_LAYER_LIGHTMAP)
	result = diffuse_map_color0;

#endif

#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_ALPHAMAP_2)
	result = BlendColor(diffuse_map_color0, diffuse_map_color1, blend_factor0);
#endif

#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_ALPHAMAP_LIGHTMAP_2)
	result = BlendColor(diffuse_map_color0, diffuse_map_color1, blend_factor0);
#endif
	
#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_ALPHAMAP_3)
	result = BlendColor(diffuse_map_color0, diffuse_map_color1, blend_factor0);
	result =  BlendColor(result, diffuse_map_color2, blend_factor1);
#endif


#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_ALPHAMAP_LIGHTMAP_3)
	result = BlendColor(diffuse_map_color0, diffuse_map_color1, blend_factor0);
	result =  BlendColor(result, diffuse_map_color2, blend_factor1);

#endif

	
#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_ALPHAMAP_4)
	result = BlendColor(diffuse_map_color0, diffuse_map_color1, blend_factor0);
	result =  BlendColor(result, diffuse_map_color2, blend_factor1);
	result =  BlendColor(result, diffuse_map_color3, blend_factor2);
#endif

#if EQUAL(TERRAIN_TECH_TYPE, TERRAIN_ALPHAMAP_LIGHTMAP_4)
	result = BlendColor(diffuse_map_color0, diffuse_map_color1, blend_factor0);
	result =  BlendColor(result, diffuse_map_color2, blend_factor1);
	result =  BlendColor(result, diffuse_map_color3, blend_factor2);
#endif

	result *= ps_general.Color.xyz;
	return result;	
}





technique TerrainTech
<
	string Description = "地形shader版本";
>
{
	pass p0
	{	
		CullMode = CW;
		
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

