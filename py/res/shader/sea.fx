#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define  SHADE_MODE SHADE_PHONG//只是为了获取Tangent,Binormal
//宏的默认值
int GlobalParameter : SasGlobal
<
	int3 SasVersion = {1,0,0};
	string SasEffectAuthoring = "hzwangchao2014";
	string SasEffectCategory = "";
	string SasEffectCompany = "Netease";
	string SasEffectDescription = "模拟水面效果的材质";

	NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN 
	//普通物体会有的
	NEOX_SASEFFECT_MACRO("开启lightmap", "LIGHT_MAP_ENABLE", "BOOL", "FASLE")  
	NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")    
	NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "TRUE")  
	NEOX_SASEFFECT_SUPPORT_MACRO_END

>;

#define FOG_TYPE FOG_TYPE_HEIGHT
#define NORMAL_MAP_ENABLE TRUE
//受雾影响和normalmap都应该是场景设的，暂时放这吧
#define FOG_ENABLE TRUE

//自定义部分
#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_EMISSIVE_MTL
#define CUSTOM_OPACITY

#include "shaderlib/pixellit.tml"
#include "shaderlib/pbr.tml"
texture	Tex0
<
	string SasUiLabel = "水小波纹法线贴图"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerWaterNormal0 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};
texture TexReflection;

sampler SampleReflectMirror = sampler_state
{
	Texture = (TexReflection);
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
};
float4	NormalTilling 
<
	string SasUiLabel = "法线Tilling"; 
	string SasUiControl = "FloatXPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "32.0";
> = 1.0;
float4	NormalSpeed 
<
	string SasUiLabel = "法线Speed"; 
	string SasUiControl = "FloatXPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "32.0";
> = 0.1;
texture	EnvironmentMap
<
	string SasUiLabel = "环境贴图";
	string SasUiControl = "FilePicker";
>;

samplerCUBE SampleEnvironmentMap = sampler_state
{
	Texture = (EnvironmentMap);
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
};

float ReflectMirrorPercent
<
	string SasUiLabel = "镜面反射率"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 1.0;
float4	PBRTest 
<
	string SasUiLabel = "PBRTest";
	string SasUiControl = "FloatXPicker";
> = float4(1.0, 1.0, 1.0, 1.0);
float4 BaseColor
<
	string SasUiLabel = "Base颜色";
	string SasUiControl = "ColorPicker";
> = float4(1.0, 1.0, 1.0, 1.0);
float4 WaterFaceColor
<
	string SasUiLabel = "水表面颜色";
	string SasUiControl = "ColorPicker";
> = float4(1.0, 1.0, 1.0, 1.0);


float4 WaterColor
<
	string SasUiLabel = "水面颜色";
	string SasUiControl = "ColorPicker";
> = float4(0.156, 0.588, 0.784, 1.0);

float4	SunDir 
<
	string SasUiLabel = "阳光角度";
	string SasUiControl = "FloatXPicker";
> = float4(0.2, 0.8, 0.5, 1.0);



float3 GetNormal(in float3 normalInTex, PS_GENERAL ps_general)
{
	float3 normalWorld = float3(0, 0, 1.0);
	float2 normalOffset = normalInTex.xy;
	normalOffset = normalOffset * 2.0 - 1.0;
	normalWorld.xy = normalOffset;
	normalWorld= normalWorld.x * ps_general.TangentWorld + normalWorld.y * ps_general.BinormalWorld + normalWorld.z * ps_general.NormalWorld;
	return normalize(normalWorld);
}

float4 GetReflectColor(PS_GENERAL ps_general, in float2 uv_offset)
{	
	float2 reflect_uv = ps_general.PosScreen.xy * 0.5 + 0.5;
	reflect_uv = reflect_uv + uv_offset * float2(0.01, 0.01);
	reflect_uv.y = 1.0 - reflect_uv.y;
	float4 reflect_color = ReflectMirrorPercent * tex2D(SampleReflectMirror, reflect_uv);

	return reflect_color;
}		

float3 GetDiffuseMtl(PS_GENERAL ps_general)
{
	return 0;
}

float Fresnel(float ndv)
{
	return 0.02 + 0.88 * pow(1.0 - ndv, 5.0);
}
float FrameTime : FrameTime;
float3 GetEmissiveMtl(in PS_GENERAL ps_general)
{
	float2 uv = ps_general.RawTexCoord0.xy * NormalTilling.x + NormalSpeed.x * FrameTime;
	float3 normalInTex = tex2D(sampleNORMAL, uv);
	uv = ps_general.RawTexCoord0.xy * NormalTilling.y + NormalSpeed.y * FrameTime;
	float3 normalWave_01 = tex2D(SamplerWaterNormal0, uv);
	normalInTex = normalize(float3(normalInTex.xy + normalWave_01,normalInTex.z));
	uv = ps_general.RawTexCoord0.xy * NormalTilling.z + NormalSpeed.z * FrameTime;
	float3 normalWave_02 = tex2D(SamplerWaterNormal0, uv);
	normalInTex = normalize(float3(normalInTex.xy + normalWave_02.xy,normalInTex.z));
	float3 normal = GetNormal(normalInTex, ps_general);

	float3 water_wave_normal = GetNormal(normalWave_01,ps_general);
		

	float3 default_wcolor = float3(0.0, 0.15, 0.115);
	float roughness = GetRoughness(1.0 - PBRTest.r);
	float metallic = GetMetallic(PBRTest.g);
	float base_map = BaseColor.rgb;
	float3 diffuse_color = GetDiffuseColor(default_wcolor, 0.0);

	float3 specular_color = 1.0;//GetSpecularColor(default_wcolor, 0.0);
	//vectors
	float3 light_dir = normalize(SunDir);
	float3 view_dir = normalize(CameraPos.xyz - ps_general.PosWorld.xyz);
	float3 half_dir = normalize(light_dir + view_dir);
	//dot indeies
	float ndh = DotClamped(normal, half_dir);
	float ndv = DotClamped(normal, view_dir);
	float ndl = DotClamped(normal, light_dir);
	float vdh = DotClamped(view_dir, half_dir);
	//diffuse
	float3 diffuse = GetBRDFDiffuse(diffuse_color);
	//specular
	float3 specular = GetBRDFSpecular(specular_color,roughness,ndh,ndv,ndl,vdh);
	// Get reflection color
	float3 NdotV_origin = dot(ps_general.NormalWorld.xyz,view_dir);
	float3 ReflectVector = normalize(2.0 * NdotV_origin * normal - view_dir);
	float3 env = texCUBE(SampleEnvironmentMap, ReflectVector);

	// Get refraction color
	// pass

	float f = Fresnel(ndv);
	float3 water_color = lerp( WaterFaceColor *(env + specular * BaseColor),WaterColor,ndv) ;
#if LIGHT_MAP_ENABLE
	float3 lightmap_clr = GetLightMapColor(ps_general);
	water_color.rgb *= lightmap_clr;
#endif
	return water_color;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float3 normalInTex = tex2D(sampleNORMAL, ps_general.TexCoord0.xy);
	float3 normal = GetNormal(normalInTex, ps_general);
	float4 reflect_color = GetReflectColor(ps_general, normal.xy);
	return reflect_color.w;
}


technique TShader
<
	string Description = "复杂海面效果";
>
{
	pass p0
	{	
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

