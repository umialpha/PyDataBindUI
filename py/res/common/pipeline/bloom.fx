float BloomIntensity <
	string SasUiLabel = "BloomIntensity";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 1.0f;
	float SasUiSteps = 0.1f;
> = 0.4f; //控制bloom强度

float BloomThreshold <		
	string SasUiLabel = "BloomThreshold";
	string SasUiControl = "FloatPicker";
	float SasUiMin = 0.0f;
	float SasUiMax = 1.0f;
	float SasUiSteps = 0.05f;
> = 0.3f; //控制bloom的阈值
	
int BloomFactor <
	string SasUiLabel = "BloomFactor";
	string SasUiControl = "IntPicker";
	int SasUiMin = 1;
	int SasUiMax = 10;
	int SasUiSteps = 0.1;
> = 2;	//控制bloom的宽度值

int BloomWidth <
	string SasUiLabel = "BloomWidth";
	string SasUiControl = "IntPicker";
	int SasUiMin = 1;
	int SasUiMax = 6;
	int SasUiSteps = 0.1;
> = 4;	//控制bloom的宽度

sampler tex0 = sampler_state
{
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
};

sampler tex1 = sampler_state
{
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
};


float4 DownSampleOffsets[16]; 

float4 DownSamplePass( in float2 t : TEXCOORD0 ) : COLOR
{ 
	float4 average = { 0.0f, 0.0f, 0.0f, 0.0f };
	for( int i = 0; i < 16; i++ )
	{
	    average += tex2D( tex0, t + float2(DownSampleOffsets[i].x, DownSampleOffsets[i].y) );
	}   
	average *= ( 1.0f / 16.0f );
	return average;
}


float4 BrightnessSampleOffsets[4];

float4 BrightnessPass( in float2 t : TEXCOORD0 ) : COLOR
{
	float4 average = { 0.0f, 0.0f, 0.0f, 0.0f };
	for( int i = 0; i < 4; i++ )
	{
	   average += tex2D( tex0, t + float2( BrightnessSampleOffsets[i].x, BrightnessSampleOffsets[i].y ) );
	}
	average *= 0.25f;
	float luminance = dot( average.rgb, float3( 0.299f, 0.587f, 0.114f ) );
	
	if(luminance < BloomThreshold)
	{
		average *= pow(abs(luminance / BloomThreshold), BloomFactor);

	}
	
	return average;
}


float HorizontalBloomWeights[9];             
float HorizontalBloomSampleOffsets[9];            

float4 HorizontalBlurPass( in float2 t : TEXCOORD0 ) : COLOR
{
	float4 color = { 0.0f, 0.0f, 0.0f, 0.0f };
	for( int i = 0; i < 9; i++ )
	{
	    color += (tex2D( tex0, t + float2( HorizontalBloomSampleOffsets[i] * BloomWidth, 0.0f ) ) * HorizontalBloomWeights[i] );
	}
	return float4( color.rgb, 1.0f );
}


float VerticalBloomWeights[9];
float VerticalBloomSampleOffsets[9];               

float4 VerticalBlurPass( in float2 t : TEXCOORD0 ) : COLOR
{
	float4 color = { 0.0f, 0.0f, 0.0f, 0.0f };
	for( int i = 0; i < 9; i++ )
	{
	    color += (tex2D( tex0, t + float2( 0.0f, VerticalBloomSampleOffsets[i] * BloomWidth ) ) * VerticalBloomWeights[i] );
	}
	float4 src = tex2D( tex1, t);
	float3 final = src.rgb + BloomIntensity * color.rgb;
	return float4( final.rgb, 1.0f );    
}

technique DownSample
{
	pass T0
	{
		Sampler[0] = (tex0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 DownSamplePass();
	}
}

technique Brightness
{
	pass T0
	{
		Sampler[0] = (tex0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 BrightnessPass();
	}
}

technique HorzBlur
{
	pass T0
	{
		Sampler[0] = (tex0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 HorizontalBlurPass();
	}
}

technique VertBlur
{
	pass T0
	{
		Sampler[0] = (tex0);
		Sampler[1] = (tex1);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 VerticalBlurPass();
	}
}
