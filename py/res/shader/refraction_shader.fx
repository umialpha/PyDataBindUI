//宏的默认值
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "lzb";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "通用的单贴图effect";
>;

float FrameTime:FrameTime;

struct VS_OUTPUT
{
   float4 pos:POSITION;
   float2 texCoord:TEXCOORD0;
   float3 normal: NORMAL;
};

float4x4 WorldViewProjMatrix: WorldViewProjection;	

VS_OUTPUT vs_main(float4 inPos:POSITION, float3 inNormal:Normal, float2 texCoord:TEXCOORD0)
{
	VS_OUTPUT result = (VS_OUTPUT)0;
	result.pos =  mul(inPos, WorldViewProjMatrix);
	//result.pos =  inPos;
	result.texCoord = texCoord;
	result.normal =  normalize(mul(inNormal.xyz, WorldViewProjMatrix).xyz);	
	return result;
}



texture	Tex0 
<
	string SasUiLabel = "diffuse0"; 
	string SasUiControl = "FilePicker";
>;
sampler	SamplerDiffuse = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};
                 
float edgealphaParams
<
	string SasUiLabel = "边缘过渡"; 
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.8f;
	float SasUiMax = 1.5f;
	float SasUiSteps = 0.05f;
> = 2.0;

float u_speed
<
	string SasUiLabel = "速度"; 
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.8f;
	float SasUiMax = 1.5f;
	float SasUiSteps = 0.05f;
> = 0.5;


float4 ps_main(VS_OUTPUT input):COLOR
{
	float len = length(input.normal.xy);
	float frenel = pow(len, edgealphaParams);
	
	float4 diffuse_color0 = tex2D(SamplerDiffuse, input.texCoord.xy + float2(u_speed, 0)* FrameTime);
	float4 diffuse_color1 = tex2D(SamplerDiffuse, input.texCoord.xy + float2(-u_speed * 0.6, u_speed * 0.3)* FrameTime);
	float4 diffuse_color = diffuse_color0 *  diffuse_color1 * 2;
	return float4(diffuse_color.xyz,  frenel);
}



technique TShader
<
	String RenderTarget = "Distortion";
>
{
	pass p0
	{	
		//AlphaBlendEnable = TRUE;
		//SrcBlend = SrcAlpha;
		//DestBlend = InvSrcAlpha;
		
		StencilEnable = true;
        StencilRef = 0xFF00FF;	//此处随便用了几位
        StencilMask = 0xFFFFFFFF;
        StencilWriteMask = 0xFFFFFFFF;
		
		StencilFunc = Always;
        StencilZFail = Keep;
        StencilPass = REPLACE;
		
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

