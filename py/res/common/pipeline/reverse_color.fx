
float reverse_factor = 1.0f;

sampler Sampler0 = sampler_state
{
	MagFilter = LINEAR;
	MinFilter = LINEAR;
	MipFilter = LINEAR;
};


float4 ReversePS(float2 t : TEXCOORD0) : COLOR
{
	float4 color = tex2D(Sampler0, t);
	float3 reverse_color = 1.0 - color.rgb;
	reverse_color = lerp(color.rgb, reverse_color, reverse_factor);
	return float4(reverse_color.rgb, color.a);
}

technique ReverseColor
{
	pass T0
	{
		Sampler[0] = (Sampler0);
		VertexShader = NULL;
		PixelShader = compile ps_2_0 ReversePS();
	}
}
