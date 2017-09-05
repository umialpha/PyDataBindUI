#define GAUSSIAN_BLUR_SCALE 7

float4 GaussianBlurParam[GAUSSIAN_BLUR_SCALE*2+1];

sampler tex0 = sampler_state
{
	MagFilter = POINT;
	MinFilter = POINT;
	MipFilter = POINT;
	AddressU = CLAMP;
	AddressV = CLAMP;
};


float4 GBV( in float2 t : TEXCOORD0 ) : COLOR
{
	float4 color = { 0.0f, 0.0f, 0.0f, 0.0f };
	for( int i = 0; i < 2 * GAUSSIAN_BLUR_SCALE; i++ )
	{
		color += (tex2D( tex0, t + float2(0, GaussianBlurParam[i].y)) * GaussianBlurParam[i].z);
	}
	return float4(color.rgb, 1.0f);
}

float4 GBH( in float2 t : TEXCOORD0 ) : COLOR
{
	float4 color = { 0.0f, 0.0f, 0.0f, 0.0f };
	for( int i = 0; i < 2 * GAUSSIAN_BLUR_SCALE; i++ )
	{
		color += (tex2D( tex0, t + float2(GaussianBlurParam[i].x, 0)) * GaussianBlurParam[i].z);
	}
	return float4(color.rgb, 1.0f);
}


technique Copy
{
	pass T0
	{
		Sampler[0] = (tex0);

		ColorOp[0] = SELECTARG1;
		ColorArg1[0] = TEXTURE;
		AlphaOp[0] = SELECTARG1;
		AlphaArg1[0] = TEXTURE;
		TexCoordIndex[0] = 0;

		VertexShader = NULL;
		PixelShader = NULL;
	}
}

technique VertBlur
{
	pass T0
	{
		Sampler[0] = (tex0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 GBV();
	}
}

technique HorzBlur
{
	pass T0
	{
		Sampler[0] = (tex0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 GBH();
	}
}
