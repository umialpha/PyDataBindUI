
//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "hzshentuyuan";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasSuportedMacros = "UnSupported ALPHA_TEST_ENABLE UnSupported FALSE;UnSupported SEPARATE_ALPHA_TEX UnSupported FALSE;";
  string SasEffectDescription = "特效序列帧";
>;

texture	Tex0 
<
	string SasUiLabel = "颜色贴图"; 
	string SasUiControl = "FilePicker";
>;

float blendValue: AlphaMtl<
> = 1.0f;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

float4 Alpha<
	string SasUiLabel = "变色"; 
	string SasUiControl = "ColorPicker";
>  = float4(253.f/255.f,235.f/255.f,228.f/255,1);

float4x4 Wvp : WorldViewProjection;
float4 SprTrans  = {1,1,0,0};
					
struct appdata {
    float3 Position	: POSITION;
    float4 UV		: TEXCOORD0;
};

struct vertexOutput {
    float4 HPosition	: POSITION;
	float4 UV		    : TEXCOORD0;
};

vertexOutput vs_main(appdata IN) {
    vertexOutput OUT = (vertexOutput)0;
    float4 Po = float4(IN.Position.xyz,1);
    OUT.HPosition = mul(Po,Wvp);
	float3x3 St = {SprTrans[0], 0, 0, 
	               0, SprTrans[1], 0,
				   SprTrans[2],SprTrans[3], 0};
	OUT.UV.xy = mul(float3(IN.UV.xy,1), St);
    return OUT;
}


					
float4 ps_main(vertexOutput IN) : COLOR 
{
	float3  uv = float3(IN.UV.xy,1);

    float4 diffuseColor = tex2D(SamplerDiffuse1,uv.xy) * Alpha*2;
    return float4(diffuseColor.xyz, diffuseColor.a*blendValue);
} 

technique TShader
<
	string Description = "普通单层贴图";
>
{
	pass p0
	{	
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

