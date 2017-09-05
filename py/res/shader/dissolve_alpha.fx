////////////////////////////////////////////////////////////////////////////////////////////////////////////
//作者:王超
//制作日期:2015.08.25
//材质说明:
//		1.利用两张不同贴图不同的UV移动方式的混合来实现变幻的表面流动效果
//		2.使用贴图来实现溶解效果,溶解参数需要外部控制来产生动态效果
//				(1) 可使用特效编辑器添加参数控制
//				(2) 可让程序外部调用控制
//		3.提供了三个宏来设置开启功能,默认全部关闭
//				(1) SEC_EMISSIVE_ENABLE 开启第二张动画贴图
//				(2) DISSOLVE_ENABLE 开启溶解效果
//				(3) RIMLIGHT_ENABLE 开启边缘光
//				(4) EMISSIVE_ANIMATION_ENABLE 开启参数控制流动效果
//第一次修改:
// 修改日期:2015.10.21
// 修改内容:
//		1.添加用参数来控制流动效果,这样可以实现用曲线来控制流动效果的目的(EMISSIVE_ANIMATION_ENABLE)
//		2.给流动增加强度控制
///////////////////////////////////////////////////////////////////////////////////////////////////////////
#define  NEED_FRAME_TIME
#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define SHADE_MODE SHADE_NONE
//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "hzwangchao2014";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "带溶解效果的两层流动uvEffect";
   
  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("使用第二张发光图", "SEC_EMISSIVE_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("使用溶解效果", "DISSOLVE_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("使用边缘光", "RIMLIGHT_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("自发光动画参数控制", "EMISSIVE_ANIMATION_ENABLE", "BOOL", "FALSE")
  //普通物体会有的
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "FALSE")  
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END
>;
//Variables :
//Textures
//Animation Textures
texture	Tex0
<
	string SasUiLabel = "滚动贴图1"; 
	string SasUiControl = "FilePicker";
	
>;
sampler	SamplerEmissive1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	
	MipMapLodBias = -0.5f;
};
#if SEC_EMISSIVE_ENABLE
texture Tex2
<
	string SasUiLabel = "滚动贴图2"; 
	string SasUiControl = "FilePicker"; 
>;
sampler SamplerEmissive2 = sampler_state
{
	Texture	  =	(Tex2);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};
#endif
#if DISSOLVE_ENABLE
//Dissolve Textures
texture Tex3
<
	string SasUiLabel = "溶解贴图"; 
	string SasUiControl = "FilePicker"; 
>;

sampler SamplerDissolve3 = sampler_state
{
	Texture	  =	(Tex3);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};
#endif
texture Tex4
<
	string SasUiLabel = "遮罩贴图"; 
	string SasUiControl = "FilePicker"; 
	string SamplerAddressU = "ADDRESS_CLAMP";
	string SamplerAddressV = "ADDRESS_CLAMP";
>;

sampler SamplerMask4 = sampler_state
{
	Texture	  =	(Tex4);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
//Uniform Variables
//Animation Variables
float4 Emissive_color 
<
string SasUiLabel = "流动光颜色"; 
string SasUiControl = "ColorPicker";
>  = float4(1, 1, 1, 0.5);
float4 Emissive_tilling
<
string SasUiLabel = "流动光参数:XY:第一张Tilling;ZW:第二Tilling"; 
string SasUiControl = "FloatXPicker";
>  = float4(1, 1, 1, 1);
float4 Emissive_speed
<
string SasUiLabel = "流动光速度参数:XY:第一张UV;ZW:第二UV"; 
string SasUiControl = "FloatXPicker";
>  = float4(1, 1, 1, 1);
// use 0 - 1 control emissive flow
//新增功能 用曲线来控制UV流动
#if EMISSIVE_ANIMATION_ENABLE
float Emissive_animation_ctrl 
<
	string SasUiLabel = "自发光流动控制"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.0;
#endif
#if RIMLIGHT_ENABLE
//Rim Variables
float4 Rim_color 
<
string SasUiLabel = "边缘光颜色"; 
string SasUiControl = "ColorPicker";
>  = float4(1.0,1.0,1.0, 0.5);
float Rim_pow//diffuse贴图动画
<
string SasUiLabel = "边缘光范围控制"; 
string SasUiControl = "FloatPicker";
string SasUiMin = "0.1";
string SasUiMax = "8.0";
> = 2.0;
#endif
#if DISSOLVE_ENABLE
//Dissolve Variables
float4 Dissolve_color 
<
string SasUiLabel = "溶解颜色"; 
string SasUiControl = "ColorPicker";
>  = float4(1.0,1.0,1.0, 1);
float Dissolve_intensity
<
string SasUiLabel = "溶解强度"; 
string SasUiControl = "FloatPicker";
string SasUiMin = "-1.0";
string SasUiMax = "1.0";

> = 0.0;
#endif
float4 Shader_Attributes
<
string SasUiLabel = "其余调节参数:XY:DissolveTilling;Z:AnimationSpeed;W:EmissiveIntensity"; 
string SasUiControl = "FloatXPicker";
string SasUiMin = "0.0";
string SasUiMax = "16.0";
> = float4(1.0,1.0,1.0,1.0);

#if DISSOLVE_ENABLE
#define DISSOLVE_TILLTING Shader_Attributes.xy
#endif
#define NORMAL_MAP_ENABLE  FALSE
#define FOG_TYPE FOG_TYPE_HEIGHT

//受雾影响和normalmap都应该是场景设的，暂时放这吧
#define FOG_ENABLE TRUE

//自定义部分
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL
#define LIGHT_MAP_ENABLE FALSE 
#define NEED_CAMERA_POS
#define FRAMETIME_SCALE 0.1
#define EMISSIVE_SCALE 4
#include "shaderlib/pixellit.tml"
//////////////////////////////////////////////////////////////////////
//
//	自发光效果获取函数
//		这里把动画效果和边缘光都归为自发光效果
//		传出为一个float4类型参数,rgb存储混合后的颜色,a存储混合后的alpha
//			rgb : screen(emissive_color , rimlight_color)
//			a : emissive_color.r + rimlight_color.r
///////////////////////////////////////////////////////////////////////
float4 GetEmissiveColor(PS_GENERAL ps_general){
	float4 result = 0.0;
	float3 emissive_color1;
	float3 emissive_color2;
	//Initialize attributes
	float animation_speed = 0.0;
#if EMISSIVE_ANIMATION_ENABLE
	animation_speed = Emissive_animation_ctrl;
#else
	animation_speed = FrameTime * FRAMETIME_SCALE ;
#endif
	float2 animation_uv1 = ps_general.RawTexCoord0.xy + Emissive_speed.xy * animation_speed;
	animation_uv1 *= Emissive_tilling.xy;
	emissive_color1 = tex2D(SamplerEmissive1,animation_uv1).rgb;
#if SEC_EMISSIVE_ENABLE
	float2 animation_uv2 = ps_general.RawTexCoord0.xy + Emissive_speed.zw * animation_speed;
	animation_uv2 *= Emissive_tilling.zw;
	emissive_color2 = tex2D(SamplerEmissive2,animation_uv2).rgb;
#endif
#if RIMLIGHT_ENABLE
	//
	float3 view_dir = normalize(CameraPos.xyz - ps_general.PosWorld.xyz);
	//Normal parameters
	float3 normal_dir = ps_general.NormalWorld.xyz;
	normal_dir = normalize(normal_dir);
	//Ks
	float NdotV = saturate(dot(normal_dir,view_dir));
#endif
	//Emissive Color
#if SEC_EMISSIVE_ENABLE
	float3 emissive_color = min(emissive_color1,emissive_color2);
#else
	float3 emissive_color = emissive_color1;
#endif
	result.a = emissive_color.r * Shader_Attributes.w;
	emissive_color *= Emissive_color.rgb * Emissive_color.a * EMISSIVE_SCALE * Shader_Attributes.w;
#if RIMLIGHT_ENABLE
	float3 rimlight_color = Rim_color.a * pow(1 - NdotV,Rim_pow)  ;
	result.a += rimlight_color.r;
	rimlight_color *= Rim_color.rgb;
#endif
#if RIMLIGHT_ENABLE
	emissive_color = saturate(1 - (1 - emissive_color) * (1 - rimlight_color));
#else
	emissive_color = emissive_color;
#endif
	result.rgb = emissive_color;
	return result;
}
//////////////////////////////////////////////////////////////////////
//
//	溶解效果获取函数
//		溶解使用采样贴图的方式来实现,用一张深度贴图来采样另外一张贴图的通道的方式来实现边缘效果,
//		这样方便做出不同程度的边缘及边缘宽度
//	返回float3类型为最终rgb颜色
///////////////////////////////////////////////////////////////////////
float3 GetDissolveAttribute(PS_GENERAL ps_general){
	float3 dissolve_color = 0.0;
#if DISSOLVE_ENABLE
	//Dissolve
	//取溶解效果贴图
	dissolve_color = tex2D(SamplerDissolve3,ps_general.TexCoord0.xy * DISSOLVE_TILLTING).rgb;
	//添加可控制的溶解参数混合
	dissolve_color -= Dissolve_intensity ;
	dissolve_color = saturate(dissolve_color);
	//通过溶解效果贴图来采样溶解控制图,获取最终的溶解状态,g通道控制溶解边缘及样式,b通道控制边缘描边宽度
	float3 dissolve_attribute = tex2D(SamplerMask4,dissolve_color.rg).rgb*2;
	dissolve_attribute = saturate(dissolve_attribute);	
#else
	float3 dissolve_attribute = 0.0;
#endif
	return dissolve_attribute;
}
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
	float3 mask_color = tex2D(SamplerMask4,ps_general.TexCoord0.xy).rgb;
	float4 emissive_color = GetEmissiveColor(ps_general);	
#if DISSOLVE_ENABLE
	float2 dissolve = GetDissolveAttribute(ps_general).gb;	
	result = dissolve.x * emissive_color.a + dissolve.y;
#else
	result =  emissive_color.a;
#endif
	result *= mask_color.r;
	return result;
}
//////////////////////////////////////////////////////////////////////
//
//	自发光函数
//		将自发光颜色 + 溶解颜色
//	返回float3
///////////////////////////////////////////////////////////////////////
float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	//base attributes
	float3 result = 0.0;
	float3 normal_dir;
	float4 emissive_color = GetEmissiveColor(ps_general);	
#if DISSOLVE_ENABLE
	//Dissolve
	float3 dissolve_attribute = GetDissolveAttribute(ps_general);
	result = emissive_color.rgb *saturate( dissolve_attribute.g - dissolve_attribute.b) +  Dissolve_color.rgb  * Dissolve_color.a * dissolve_attribute.b  ;
#else
	result = emissive_color.rgb;
#endif
	return result;
}

technique TShader
<
	string Description = "带溶解效果的两层流动uvEffect";
>
{
	pass p0
	{	
	//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

