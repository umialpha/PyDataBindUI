int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "hzliuran";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "plasma";
  string SasSuportedMacros = "ÊÇ·ñ³Ë¶¥µãÉ« VCOLOR_ENABLE BOOL FALSE;";
  string SasEffectAttr = "INSTANCE_SUPPORTED=FALSE;";
>;

texture	Tex0 : DiffuseMap
<
	string SasUiLabel = "ÑÕÉ«ÌùÍ¼"; 
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

texture	Tex1
<
	string SasUiLabel = "ramp"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerRamp= sampler_state
{
	Texture	  =	(Tex1);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	MipMapLodBias = -0.5f;
};

float4x4 WorldViewProj	: WorldViewProjection;
float4x4 WorldViewMatrix: WorldView;
float4x4 TexTransMatrix0: TexTransform0;

float4 blend_color = float4(1,1,1,1);
float4 texuv_clamp
<
	string SasUiLabel = "UV·¶Î§"; 
> = float4(0,0,1,1);

float frequency
<
	string SasUiLabel = "²¨¶¯ÆµÂÊ";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 2.0f;
	float SasUiSteps = 0.01f;
> = 1.0;

float amplitude
<
	string SasUiLabel = "²¨¶¯·ù¶È";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 10.0f;
	float SasUiSteps = 0.1f;
> = 1;

float wave_size
<
	string SasUiLabel = "²¨¶¯³ß¶È";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 10.0f;
	float SasUiSteps = 0.1f;
> = 1;

float displace_offset
<
	string SasUiLabel = "Î»ÒÆÆ«ÒÆ";
	string SasUiControl = "FloatPicker";
> = 0.0;

float ramp_scale
<
	string SasUiLabel = "rampËõ·Å";
	string SasUiControl = "FloatPicker";
> = 1.0;

float ramp_offset
<
	string SasUiLabel = "rampÆ«ÒÆ";
	string SasUiControl = "FloatPicker";
> = -0.5;

float dissolve
<
	string SasUiLabel = "ÏûÉ¢";
	string SasUiControl = "FloatPicker";
> = 0;

float dissolve_hardness
<
	string SasUiLabel = "ÏûÉ¢Ó²¶È";
	string SasUiControl = "FloatPicker";
> = 10;

struct VS_in { 
	float4 pos			: POSITION;
	float4 point_color	: COLOR;
	float4 tex0			: TEXCOORD0;
	float4 normal 		: NORMAL;
}; 

struct VS_out { 
	float4 pos			: POSITION;
	float4 point_color	: COLOR;
	float4 tex0			: TEXCOORD0;
	float4 weight		: TEXCOORD1;
}; 

float Time : FrameTime;

float3 point_noise(float3 p, float time)
{
	float3 p2 = (p + time) * float3(1.0, 1.5, 2.0);
	return sin(p2);
}

VS_out VS_main( VS_in In )
{
	VS_out Out = (VS_out)0;

	// Noise Generation
	float4 np = In.pos / wave_size;
	float t = Time * frequency;
	float3 p2 = np.xyz - np.yzx;

	float3 noise = point_noise(p2, t) + 1.0;
	float sum_noise = noise.x + noise.y + noise.z;

	// Output noise to PS
	Out.weight.xyz = noise / sum_noise;
	Out.weight.w = sum_noise / 6.0;

	// Move vertices based on noise
	float4 pos = In.pos;
	pos.xyz += (sum_noise - 3.0 + displace_offset) * In.normal * amplitude;

	// Calculate other stuff
	Out.pos = mul(pos, WorldViewProj);
	Out.tex0.xyz = mul(float3(In.tex0.xy,1), (float3x3)TexTransMatrix0);
	Out.point_color = In.point_color;

	return Out;
}

float4 PS_main( VS_out In): COLOR
{
	float4 texcolor = tex2D(SamplerDiffuse1, In.tex0.xy);
	float level = dot(In.weight, texcolor.xyz) + In.weight.w;
	texcolor = tex2D(SamplerRamp, float2(level, 0.5) * ramp_scale + ramp_offset);

#if VCOLOR_ENABLE
	texcolor *= In.point_color;
#endif
	texcolor.a = (level - dissolve) * dissolve_hardness;
	return texcolor;
}

technique TShader
{
	pass P0
	{
		//ZWriteEnable = FALSE;
		CullMode = None;
		VertexShader = compile vs_2_0 VS_main();
		PixelShader = compile ps_2_0 PS_main(); 
	}	
}