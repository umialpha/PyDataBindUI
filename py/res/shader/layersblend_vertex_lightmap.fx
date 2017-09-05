#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define SHADE_MODE SHADE_NONE
//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "lzb";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "通用的单贴图effect";
   
  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("是否高光", "NEOX_SPECULAR_ENABLE", "BOOL", "FALSE")  
  NEOX_SASEFFECT_MACRO("是否环境贴图", "CUBEMAP_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("是否高光遮罩", "NEOX_SPECULAR_MASK_ENABLE", "BOOL", "FALSE") 
  NEOX_SASEFFECT_MACRO("是否动态灯光", "DYNAMIC_LIGHT_ENABLE", "BOOL", "FALSE")
  
  //普通物体会有的
  NEOX_SASEFFECT_MACRO("UnSupported", "GPU_SKIN_ENABLE", "UnSupported", "FALSE") 
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "TRUE")
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END
>;


texture	Tex0
<
	string SasUiLabel = "R通道贴图"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -1.0f;
};
	
texture	MixTex2
<
	string SasUiLabel = "G通道贴图"; 
	string SasUiControl = "FilePicker";
>;

sampler SamplerMixTex2 = sampler_state
{
	Texture	  =	(MixTex2);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -1.0f;
};


texture	MixTex3
<
	string SasUiLabel = "B通道贴图"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerMixTex3 = sampler_state
{
	Texture	  =	(MixTex3);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -1.0f;
};

//texture	MixTex4
//<
//	string SasUiLabel = "A通道贴图"; 
//	string SasUiControl = "FilePicker";
//>;

//sampler	SamplerMixTex4 = sampler_state
//{
//	Texture	  =	(MixTex4);
//	MipFilter =	LINEAR;
//	MinFilter =	LINEAR;
//	MagFilter =	LINEAR;
//	MipMapLodBias = -1.0f;
//};

float4 Tex_scale
<
string SasUiLabel = "贴图Tilling"; 
string SasUiControl = "FloatXPicker";
>  = float4(1, 1, 1, 1);

float change_color_bright
<
	string SasUiLabel = "自发光"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.0;

float ShadowAlpha
<
	string SasUiLabel = "实时阴影透明度";
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.2;

float dark_factor
<
	string SasUiLabel = "压暗程度";
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 1.0;

#if CUBEMAP_ENABLE
	texture	CubeMap5
	<
		string SasUiLabel = "cubemap混合贴图";  //R:tex1控制贴图 G:tex2控制贴图 B:tex3控制贴图 A:Cube反射贴图
		string SasUiControl = "FilePicker";
		string TextureFile = "common\\textures\\white.tga";
	>;
	
	sampler	SamplerDiffuse3 = sampler_state
	{
		Texture	  =	(CubeMap5);
		MipFilter =	LINEAR;
		MinFilter =	LINEAR;
		MagFilter =	LINEAR;
		MipMapLodBias = -1.0f;
	};
	
	float CubeMapPower
	<
		string SasUiLabel = "环境贴图强度";
		string SasUiControl = "FloatPicker";
	> = 1.0;
	
	float4 cubemap_color
	<
		string SasUiLabel = "环境贴图颜色"; 
		string SasUiControl = "ColorPicker";
	>  = float4(1, 1, 1, 0.5);
#endif



#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE FALSE
//#define FOG_TYPE FOG_TYPE_LINER
#define FOG_TYPE FOG_TYPE_HEIGHT
//受雾影响和normalmap都应该是场景设的，暂时放这吧
#define FOG_ENABLE TRUE

//自定义部分
#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL

#define LIGHT_MAP_ENABLE TRUE
#define AMBIENT_COLOR_ENABLE FALSE

#include "shaderlib/pixellit.tml"
const float4 camera_pos:CameraPosition;
// static float view_control = 2.5; //控制地形高光在依据法线变化的情况，越大，衰减越快
// static float screen_control = 2.5; //控制地形高光在屏幕位置衰减情况，越大，从中心开始衰减越快


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

float3 GetDiffuseMtl(PS_GENERAL ps_general)
{	
	float4 vertex_color = ps_general.Color;
	float4 mix_tex_1 = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy*Tex_scale.x);
	float4 mix_tex_2 = tex2D(SamplerMixTex2, ps_general.TexCoord0.xy*Tex_scale.y);
	float4 mix_tex_3 = tex2D(SamplerMixTex3, ps_general.TexCoord0.xy*Tex_scale.z);
	//float4 mix_tex_4 = tex2D(SamplerMixTex4, ps_general.TexCoord0.xy*Tex_scale.w);
	float3 diffuse_map_color = lerp((((vertex_color.r * mix_tex_1.rgb) + (vertex_color.g * mix_tex_2.rgb)) + (vertex_color.b * mix_tex_3.rgb)), mix_tex_1.rgb, (1.0 - vertex_color.a));
	//float4 diffuse_map_color = mix_tex_1*vertex_color.r + mix_tex_2*vertex_color.g + mix_tex_3*vertex_color.b + mix_tex_4*vertex_color.a;
	diffuse_map_color *= dark_factor;
	return diffuse_map_color.xyz;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	return diffuse_map_color.a;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general )
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	
	if(is_multipy_vector)
	{
		diffuse_map_color*= ps_general.Color;
	}
	
	float3  emissive_color= diffuse_map_color.xyz * change_color_bright;
	
	#if CUBEMAP_ENABLE
	float2 reflect_uv = ps_general.PosScreen.xy * 0.5 + 0.5;
	reflect_uv.y = 1.0 - reflect_uv.y;
	
	float4 vertex_color = ps_general.Color;
	float cubemap_mask_r = tex2D(SamplerDiffuse3, ps_general.TexCoord0.xy*Tex_scale.x).x;
	float cubemap_mask_g = tex2D(SamplerDiffuse3, ps_general.TexCoord0.xy*Tex_scale.y).y;
	float cubemap_mask_b = tex2D(SamplerDiffuse3, ps_general.TexCoord0.xy*Tex_scale.z).z;
	float cubemap_shape = tex2D(SamplerDiffuse3, reflect_uv.xy).w;//
	emissive_color += lerp(((vertex_color.r * cubemap_mask_r) + (vertex_color.g * cubemap_mask_g)), cubemap_mask_b, vertex_color.b) * CubeMapPower * cubemap_color * cubemap_shape;
	
	#endif
	
	return emissive_color;
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
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

