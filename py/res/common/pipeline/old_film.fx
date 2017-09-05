sampler2D TexSampler = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
};
  
texture texture_background
<
	string SasUiLabel = "噪声贴图";
	string SasUiControl = "TexturePicker";
	string TextureFile = "common\\textures\\scratch.dds"; 
>;

sampler2D ToneSampler:register(s3) = sampler_state
{
	Texture = (texture_background);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
}; 

//映射图
texture	texture_lut
<
	string SasUiLabel = "LutTexture";
	string SasUiControl = "TexturePicker";
	int TextureType = 6;
	string TextureFile = "common\\textures\\old_film.png"; 
>;

sampler3D LutSampler = sampler_state
{
	Texture = (texture_lut);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};



float4 geometry_map_size : GLBufferSize = 0;

float time_fac
<
	string SasUiLabel = "播放速度";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 15.0f;
	float SasUiSteps = 0.1f;
> = 4.0f;

float noise_scale
<
	string SasUiLabel = "尺度缩放";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 4.0f;
	float SasUiSteps = 0.1f;
> = 1.0f;


float noise_intensity_r
<
	string SasUiLabel = "刮痕强度";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 1.0f;
	float SasUiSteps = 0.1f;
> = 0.5f;

float noise_intensity_g
<
	string SasUiLabel = "折痕强度";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 1.0f;
	float SasUiSteps = 0.1f;
> = 0.3f;

float noise_intensity_b
<
	string SasUiLabel = "噪声强度";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 1.0f;
	float SasUiSteps = 0.1f;
> = 0.3f;





float FrameTime: FrameTime;

struct VS_OUTPUT_BLUR
{
    float4 Position   : POSITION; 
	float4 Coord0		: TEXCOORD0;	
};


VS_OUTPUT_BLUR vs_main(float3 Position : POSITION, 
			float2 TexCoord : TEXCOORD0)
{
    VS_OUTPUT_BLUR OUT = (VS_OUTPUT_BLUR)0;	
	OUT.Position.xyz = Position;
	OUT.Position.w= 1;
	OUT.Coord0.xy = TexCoord;
	
	return OUT;
}


//画面本身的色调使用colorgrading
//划痕加上时间因子
float4 ps_main(VS_OUTPUT_BLUR input) : COLOR
{  

	//原图
	float4 org_clr = tex2D(TexSampler, input.Coord0 +  0.5f/geometry_map_size);
	
	//color_grading
	int lut_size = 16;
	float4 scale = (lut_size - 1.0) / lut_size;
	float4 offset = 1.0 / (2.0 * lut_size);
	float4 illum = tex3D(LutSampler, scale * org_clr + offset);
	
	//噪声图
	//随机uv
	float time_val = FrameTime * time_fac;
	int time_intenger = 0;
	float time_fac = modf(time_val, time_intenger);
	

	
	//划痕
	float2 noise_bias = float2(time_intenger * 1.37, time_intenger * 1.79); 
	float4 noise_clr = tex2D(ToneSampler, input.Coord0 * noise_scale + noise_bias);
		
		//混合
	float4 blend_clr = illum +   dot(noise_clr.rgb,float3(noise_intensity_r,noise_intensity_g,noise_intensity_b));
	
	
	return blend_clr;
	

}



technique Tech
{
	pass T0
	{
		Sampler[0] = (TexSampler);
		VertexShader = compile vs_2_0 vs_main();
		PixelShader = compile ps_2_0 ps_main();
	}
}
