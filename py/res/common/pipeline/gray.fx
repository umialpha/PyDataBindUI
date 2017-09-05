
float gray_factor = 1.0f;

sampler Sampler0 = sampler_state
{
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
};


float4 GrayPS(float2 t : TEXCOORD0) : COLOR
{
	float4 color = tex2D(Sampler0, t);
	float3 gray_color = dot( color.rgb, float3(0.299f, 0.587f, 0.114f));
	gray_color = lerp(gray_color, color.rgb, gray_factor);
	return float4(gray_color.rgb, 1.0f);
}

technique Gray
{
	pass T0
	{
		Sampler[0] = (Sampler0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 GrayPS();
	}
}
