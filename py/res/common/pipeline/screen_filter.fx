
float4 screen_color = float4(1.0f, 1.0f, 1.0f, 0.0f);

sampler Sampler0 = sampler_state
{
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
};


float4 ColorPS(float2 t : TEXCOORD0) : COLOR
{
	float4 color = tex2D(Sampler0, t);
	float3 new_color = lerp(color.rgb, screen_color.rgb, screen_color.w);
	return float4(new_color.rgb, 1.0f);
}

technique ScreenFilter
{
	pass T0
	{
		Sampler[0] = (Sampler0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 ColorPS();
	}
}
