sampler Texture0 : register(s0);
float2 TexSize0 = 0;
sampler Texture1 : register(s1);
float2 TexSize1 = 0;

float distortionScale = 0.02;

float4 main(float2 texCoord : TEXCOORD0) : COLOR
{
   //return float4(1,1,0,1);
   float2 bias0 =0.5/ TexSize0;	
   float2 bias1 =0.5/ TexSize1;	
   float2 distort = tex2D(Texture1, texCoord + bias1).xy - 0.5;


   return tex2D(Texture0, texCoord - distortionScale * distort + bias0);
}

technique Distortion
{
	pass T0
	{
		VertexShader = NULL;
		PixelShader = compile ps_2_0 main();
		
		StencilEnable = true;
        StencilRef = 0xFF00FF;	//此处随便用了几位
        StencilMask = 0xFF00FF;
     		
		StencilFunc = Equal;
        StencilZFail = Keep;
        StencilPass = Keep;
	}
}
