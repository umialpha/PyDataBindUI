#include "common_defination.fx"
#include "shaderlib/common.fxl"
#include "shaderlib/pixellit.tml"
//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "lqz";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "通用的单贴图effect";
>;

texture	Tex0 : DiffuseMap
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

float alpha
<
	string SasUiLabel = "alpha"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 1.0;


float4 pps_main(VS_OUTPUT IN):COLOR
{
	float4 color =  tex2D(SamplerDiffuse1,IN.TexCoord0.xy);
	float4 res = float4(color.xyz,color.w*alpha);
	return res;
}

float4 pps2_main(VS_OUTPUT IN):COLOR
{
	float4 color =  tex2D(SamplerDiffuse1,IN.TexCoord0.xy);
	float4 res = float4(color.xyz,color.w*alpha);
	return res;
}
 
technique TShader
<
	string Description = "普通单层贴图";
>
{
	pass p0
	{	
		VertexShader = compile vs_3_0  vs_main();
		PixelShader = compile ps_3_0  pps_main();
	}
}

technique TShaderMirror
<
	string Description = "普通单层贴图";
>
{
	pass p0
	{	
		VertexShader = compile vs_3_0  vs_main();
		PixelShader = compile ps_3_0  pps2_main();
	}
}
