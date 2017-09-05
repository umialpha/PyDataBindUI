#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define  SHADE_MODE SHADE_PHONG//只是为了获取Tangent,Binormal

//宏的默认值
int GlobalParameter : SasGlobal
<
int3 SasVersion = { 1, 0, 0 };
string SasEffectAuthoring = "hzwangchao2014";
string SasEffectCategory = "";
string SasEffectCompany = "Netease";
string SasEffectDescription = "X9m场景通用effect";

NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
NEOX_SASEFFECT_MACRO("lightmap", "LIGHT_MAP_ENABLE", "BOOL", "TRUE")
NEOX_SASEFFECT_MACRO("阴影", "RECEIVE_SHADOW", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("高光贴图", "SPECULAR_MAP_ENABLE", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("法线贴图", "USE_NORMAL_MAP", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("雾", "FOG_ENABLE", "BOOL", "FALSE")


//普通物体会有的  

NEOX_SASEFFECT_SUPPORT_MACRO_END

NEOX_SASEFFECT_ATTR_BEGIN
NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "FALSE")
NEOX_SASEFFECT_ATTR_END
>;

float FrameTime : FrameTime;


texture	Tex0
<
string SasUiLabel = "颜色贴图";
string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture = (Tex0);
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipMapLodBias = -0.5f;
};

texture Tex3
<
string SasUiLabel = "SpecularMap";
string SasUiControl = "FilePicker";
>;

sampler SamplerSpecular = sampler_state
{
	Texture = (Tex3);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};

#if USE_NORMAL_MAP
texture Tex4
<
string SasUiLabel = "NormalMap";
string SasUiControl = "FilePicker";
>;

sampler SamplerNormal = sampler_state
{
	Texture = (Tex4);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};
#endif


texture Tex5
<
string SasUiLabel = "RainMap";
string SasUiControl = "FilePicker";
>;


sampler	SamplerRain = sampler_state
{
	Texture = (Tex5);
	MipFilter = LINEAR;
};

float change_color_bright
<
	string SasUiLabel = "自发光";
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.0;
float4 specular_control
<
	string SasUiLabel = "高光控制";
	string SasUiControl = "FloatXPicker";
> = float4(1.0, 1.0, 1.0, 1.0);

float normalmap_factor
<
	string SasUiLabel = "法线贴图强度"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "2.0";
> = 1.0;

#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE TRUE
#define FOG_TYPE FOG_TYPE_HEIGHT

//受雾影响和normalmap都应该是场景设的，暂时放这吧
#define FOG_ENABLE TRUE

//自定义部分
#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL



#include "shaderlib/pixellit.tml"
static float view_control = 2.5; //控制地形高光在依据法线变化的情况，越大，衰减越快
static float screen_control = 2.5; //控制地形高光在屏幕位置衰减情况，越大，从中心开始衰减越快



bool is_multipy_vector
<
string SasUiLabel = "是否乘顶点色";
string SasUiControl = "ListPicker_BOOL";
> = false;

//只在烘焙光照贴图的时候把此参数传递给cloudgi，shader并中不使用这个参数
bool cloudgi_same_direction
<
string SasUiLabel = "同向法线";
string SasUiControl = "ListPicker_BOOL";
> = false;

float rain_tiling
<
string SasUiLabel = "Tiling";
string SasUiControl = "FloatPicker";
> = 1.0;

float flow_speed_x
<
string SasUiLabel = "流动速度X";
string SasUiControl = "FloatPicker";
> = 0.025;

float flow_speed_y
<
string SasUiLabel = "流动速度Y";
string SasUiControl = "FloatPicker";
> = 0.025;

float3 GetDiffuseMtl(PS_GENERAL ps_general)
{
	return 0.0;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);
	float result = diffuse_map_color.a;
	return result;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);

// #if LIGHT_MAP_ENABLE
// 	float3 lightmap_clr = GetLightMapColor(ps_general);
// 	diffuse_map_color.rgb *= lightmap_clr;
// #endif

	float3 normal = ps_general.NormalWorld;
	float3 light_dir = float3(-0.660, -0.583, 0.474); //DirLightAttr[3].xyz;

#if USE_NORMAL_MAP
	float3 Tangent = ps_general.TangentWorld.xyz;
	float3 Binormal = ps_general.BinormalWorld.xyz;
	float3 normal_offset = float3(0.0, 0.0, 1.0);
	normal_offset.xy = tex2D(SamplerNormal, ps_general.TexCoord0.xy).xy;
	//normal_offset.z = 1 - normal_offset.x - normal_offset.y;
	normal_offset.xy = normal_offset.xy * 2.0 - 1.0;
	normal = normalize(normal_offset.x * Tangent + normal_offset.y * Binormal + normal_offset.z * normal);
	float LdotN_NormalMap = dot(-light_dir, normal.xyz);
	float LdotN_Original = dot(-light_dir, ps_general.NormalWorld.xyz);
	float ratio = 1.0 + (LdotN_NormalMap - LdotN_Original) * normalmap_factor;
	diffuse_map_color.rgb *= ratio;
#endif	

	float3 view_dir = normalize(CameraPos.xyz - ps_general.PosWorld.xyz);

	float4 specular_color = float4(0.0, 0.0, 0.0, 0.0);
#if SPECULAR_MAP_ENABLE
	specular_color = tex2D(SamplerSpecular, ps_general.TexCoord0.xy);
	float3 half_vec = normalize(view_dir.xyz - light_dir.xyz);
	float NdotH = saturate(dot(normal, half_vec));
	specular_color.rgb *= pow(NdotH, specular_control.g);
	diffuse_map_color.rgb += specular_color;
#endif
	
	float2 offset_uv = ps_general.TexCoord0.xy + FrameTime * float2(flow_speed_x, flow_speed_y);
	float4 rain_mask = tex2D(SamplerRain, ps_general.TexCoord0.xy);
	float2 offset_map = tex2D(SamplerRain, offset_uv);
	float2 rain_uv = ps_general.TexCoord0.xy + float2(offset_map.x, offset_map.x);
	float3 rain_color = tex2D(SamplerRain, rain_uv * rain_tiling).g;
	float shininess = rain_mask.b;

#if SPECULAR_MAP_ENABLE
	rain_color *= (1.0 + pow(NdotH, 5.0));
#endif

	//return diffuse_map_color.rgb + rain_color * rain_mask.b;
	return lerp(diffuse_map_color.rgb, rain_color, rain_mask.b);
}

technique TShader
<
string Description = "普通单层贴图";
>
{
	pass p0
	{
		//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader = compile ps_3_0 ps_main();
	}
}

